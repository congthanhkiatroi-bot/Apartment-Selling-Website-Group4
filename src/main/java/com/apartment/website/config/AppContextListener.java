package com.apartment.website.config;

import com.apartment.website.property.repository.PropertyRepository;
import com.apartment.website.property.repository.PropertyRepositoryJdbc;
import com.apartment.website.property.repository.PropertyRepositoryMock;
import com.apartment.website.property.service.PropertyService;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * "Nơi lắp ráp" thay cho @Autowired / @Service / @Repository của Spring:
 * chạy 1 lần khi Tomcat khởi động, tự tay new các đối tượng và truyền vào nhau qua constructor,
 * rồi cất vào ServletContext để các Servlet lấy ra dùng.
 */
@WebListener
public class AppContextListener implements ServletContextListener {
    public static final String PROPERTY_SERVICE = "propertyService";

    @Override
    public void contextInitialized(ServletContextEvent event) {
        ServletContext ctx = event.getServletContext();
        ctx.setAttribute("ctx", ctx.getContextPath());                 // JSP dùng ${ctx} để ghép đường dẫn

        boolean usePg = Database.get("data.mode", "mock").equalsIgnoreCase("postgres");
        PropertyRepository propertyRepository = usePg ? new PropertyRepositoryJdbc() : new PropertyRepositoryMock();
        PropertyService propertyService = new PropertyService(propertyRepository);   // = @Autowired bằng constructor
        ctx.setAttribute(PROPERTY_SERVICE, propertyService);

        // Thêm tính năng mới: new XxxRepository -> new XxxService(repo) -> ctx.setAttribute(...)
        ctx.log("Apartment web khoi dong, data.mode=" + (usePg ? "postgres" : "mock"));
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) { Database.shutdown(); }
}
