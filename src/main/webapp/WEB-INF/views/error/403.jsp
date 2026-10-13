<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" session="false" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Không đủ quyền truy cập</title>
  <link rel="stylesheet" href="${ctx}/css/base.css">
  <link rel="stylesheet" href="${ctx}/css/layout.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/partials/header.jsp"/>
<main class="container page" style="text-align:center;padding:80px 16px">
  <h1 style="font-size:48px;color:var(--green)">Không đủ quyền truy cập</h1>
  <p style="margin:12px 0 24px">
    <c:choose>
      <c:when test="${requiredRole == 'OWNER'}">Chức năng đăng tin chỉ dành cho tài khoản <b>Chủ căn hộ</b>.</c:when>
      <c:otherwise>Chức năng đặt lịch xem nhà chỉ dành cho tài khoản <b>Khách hàng</b>.</c:otherwise>
    </c:choose>
    Bạn có thể đăng xuất rồi đăng ký tài khoản đúng vai trò.
  </p>
  <a class="btn btn--primary" href="${ctx}/">Về trang chủ</a>
</main>
<jsp:include page="/WEB-INF/views/partials/footer.jsp"/>
</body>
</html>
