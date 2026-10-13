<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" session="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="header">
  <div class="container navbar">
    <a href="${ctx}/" class="logo"><div class="logo-icon">⌂</div><span>Apartment</span></a>
    <nav class="nav-menu">
      <a href="${ctx}/" class="${active == 'home' ? 'active' : ''}">Trang chủ</a>
      <a href="${ctx}/properties" class="${active == 'list' ? 'active' : ''}">Danh sách căn hộ</a>
      <a href="${ctx}/postings/create" class="${active == 'post' ? 'active' : ''}">Đăng tin</a>
      <a href="${ctx}/postings" class="${active == 'manage' ? 'active' : ''}">Quản lí tin</a>
      <a href="${ctx}/comparisons" class="${active == 'compare' ? 'active' : ''}">So sánh</a>
      <a href="${ctx}/appointments" class="${active == 'schedule' ? 'active' : ''}">Lịch xem</a>
      <a href="${ctx}/about" class="${active == 'about' ? 'active' : ''}">Về chúng tôi</a>
    </nav>
    <div class="header-actions">
      <button class="notification-btn" type="button" title="Thông báo">🔔<span class="notification-dot"></span></button>
      <c:choose>
        <c:when test="${not empty currentUser}">
          <span style="font-size:14px;font-weight:600"><c:out value="${currentUser.displayName}"/>
            (${currentUser.owner ? 'Chủ căn hộ' : currentUser.admin ? 'Quản trị' : 'Khách hàng'})</span>
          <form method="post" action="${ctx}/logout" style="margin:0">
            <button type="submit" class="login-btn" style="border:0;cursor:pointer">Đăng xuất</button>
          </form>
        </c:when>
        <c:otherwise>
          <a href="${ctx}/login" class="login-btn">Đăng nhập</a>
          <a href="${ctx}/register" class="login-btn" style="background:#fff;color:var(--green);border:1.5px solid var(--green)">Đăng ký</a>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</header>
