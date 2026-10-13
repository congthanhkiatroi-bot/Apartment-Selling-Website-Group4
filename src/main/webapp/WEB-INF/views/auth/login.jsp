<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" session="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Đăng nhập - Apartment</title>
  <link rel="stylesheet" href="${ctx}/css/auth.css">
</head>
<body class="auth">
<main class="auth-shell">
  <section class="auth-brand">
    <div class="auth-badge">APARTMENT SALES AND<br>TRANSACTION MANAGEMENT</div>
    <a class="auth-logo" href="${ctx}/">▲ Apartment Management</a>
    <h2>Khám phá căn hộ<br>hoàn hảo cho<br>cuộc sống của bạn</h2>
    <p>Hệ thống quản lý mua bán, tìm kiếm và giao dịch bất động sản chuyên nghiệp.</p>
  </section>

  <section class="auth-panel">
    <h1>Đăng nhập</h1>
    <c:if test="${not empty next and empty error}"><div class="a-alert err">Bạn cần đăng nhập để sử dụng chức năng này.</div></c:if>
    <c:if test="${param.registered == '1'}"><div class="a-alert ok">Đăng ký thành công. Hãy đăng nhập để tiếp tục.</div></c:if>
    <c:if test="${not empty error}"><div class="a-alert err" role="alert"><c:out value="${error}"/></div></c:if>

    <form method="post" action="${ctx}/login">
      <input type="hidden" name="next" value="<c:out value='${next}'/>">
      <div class="a-field">
        <input class="a-input" type="text" name="identity" placeholder="SĐT chính hoặc email" autocomplete="username" required
               value="<c:out value='${identity}'/>">
      </div>
      <div class="a-field">
        <input class="a-input" type="password" name="password" placeholder="Mật khẩu" autocomplete="current-password" required>
      </div>
      <div class="a-forgot"><a href="#" onclick="alert('Chức năng quên mật khẩu chưa được cài đặt.');return false;">Quên mật khẩu?</a></div>
      <button class="a-btn" type="submit">Đăng nhập</button>
    </form>
    <p class="a-switch">Bạn chưa có tài khoản? <a href="${ctx}/register">Đăng ký</a></p>
    <a class="a-home" href="${ctx}/">← Về trang chủ</a>
  </section>
</main>
</body>
</html>
