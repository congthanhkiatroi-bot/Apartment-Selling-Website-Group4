package com.apartment.website.config;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Proxy;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

/**
 * Đọc app.properties (ưu tiên biến môi trường, vd db.url -> DB_URL) và cung cấp kết nối PostgreSQL
 * qua một connection pool tự viết: dùng xong gọi close() là trả lại pool chứ không đóng thật.
 */
public final class Database {
    private static final int POOL_SIZE = 8;   // không vượt quá max_connections của PostgreSQL
    private static final Properties P = new Properties();
    private static final BlockingQueue<Connection> IDLE = new LinkedBlockingQueue<>();
    private static int created = 0;
    private static boolean driverLoaded = false;

    static {
        try (InputStream in = Database.class.getResourceAsStream("/app.properties")) {
            if (in != null) P.load(new InputStreamReader(in, StandardCharsets.UTF_8));
        } catch (IOException e) { throw new ExceptionInInitializerError(e); }
    }

    private Database() {}

    public static String get(String key, String def) {
        String env = System.getenv(key.toUpperCase().replace('.', '_'));
        return (env != null ? env : P.getProperty(key, def)).trim();
    }

    private static Connection open() throws SQLException {
        if (!driverLoaded) {   // Tomcat: cần nạp driver thủ công để DriverManager thấy driver trong WEB-INF/lib
            try { Class.forName("org.postgresql.Driver"); driverLoaded = true; }
            catch (ClassNotFoundException e) { throw new SQLException("Thiếu driver PostgreSQL (postgresql.jar)", e); }
        }
        return DriverManager.getConnection(get("db.url", ""), get("db.user", ""), get("db.password", ""));
    }

    /** Mượn 1 kết nối. LUÔN dùng try-with-resources để tự động trả lại. */
    public static Connection getConnection() throws SQLException {
        Connection real = IDLE.poll();
        if (real == null) {
            synchronized (Database.class) {
                if (created < POOL_SIZE) { real = open(); created++; }
            }
            if (real == null) {                                        // pool đầy -> chờ người khác trả
                try { real = IDLE.poll(5, TimeUnit.SECONDS); }
                catch (InterruptedException e) { throw new SQLException(e); }
                if (real == null) throw new SQLException("Hết kết nối trong pool");
            }
        }
        if (real.isClosed() || !real.isValid(2)) real = open();       // kết nối chết -> mở cái mới thay
        final Connection conn = real;
        final boolean[] returned = {false};
        return (Connection) Proxy.newProxyInstance(Connection.class.getClassLoader(), new Class<?>[]{Connection.class},
                (proxy, method, args) -> {
                    if (method.getName().equals("close")) {
                        if (!returned[0]) {
                            returned[0] = true;
                            if (!conn.getAutoCommit()) { conn.rollback(); conn.setAutoCommit(true); }
                            IDLE.offer(conn);
                        }
                        return null;
                    }
                    try { return method.invoke(conn, args); }
                    catch (InvocationTargetException e) { throw e.getCause(); }
                });
    }

    /** Gọi khi Tomcat tắt ứng dụng. */
    public static void shutdown() {
        Connection c;
        while ((c = IDLE.poll()) != null) try { c.close(); } catch (SQLException ignored) {}
    }
}
