<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" session="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Đăng ký - Apartment</title>
  <link rel="stylesheet" href="${ctx}/css/auth.css">
</head>
<body class="auth">
<main class="auth-shell">
  <section class="auth-brand">
    <div class="auth-badge">APARTMENT SALES AND<br>TRANSACTION MANAGEMENT</div>
    <a class="auth-logo" href="${ctx}/">▲ Apartment Management</a>
    <h2 id="brandTitle">Tạo tài khoản<br>khách hàng mới</h2>
    <p id="brandText">Trở thành thành viên để dễ dàng giao dịch, quản lý căn hộ và nhận các tiện ích tốt nhất.</p>
  </section>

  <section class="auth-panel">
    <h1>Đăng ký thông tin</h1>
    <form id="regForm" method="post" action="${ctx}/register">
      <div class="a-label">Bạn đăng ký với vai trò</div>
      <div class="a-roles">
        <label>
          <input type="radio" name="role" value="CUSTOMER" ${form.role != 'OWNER' ? 'checked' : ''}>
          <span><b>Khách hàng</b><small>Tìm mua, thuê, đặt lịch xem</small></span>
        </label>
        <label>
          <input type="radio" name="role" value="OWNER" ${form.role == 'OWNER' ? 'checked' : ''}>
          <span><b>Chủ căn hộ</b><small>Đăng tin bán, cho thuê</small></span>
        </label>
      </div>
      <c:if test="${not empty errors.role}"><div class="a-msg" style="margin:-8px 0 12px"><c:out value="${errors.role}"/></div></c:if>

      <div class="a-field ${not empty errors.fullName ? 'bad' : ''}">
        <input class="a-input" type="text" name="fullName" placeholder="Họ và tên đầy đủ" autocomplete="name" required maxlength="150"
               value="<c:out value='${form.fullName}'/>">
        <c:if test="${not empty errors.fullName}"><div class="a-msg"><c:out value="${errors.fullName}"/></div></c:if>
      </div>
      <div class="a-field ${not empty errors.phone ? 'bad' : ''}">
        <input class="a-input" type="tel" name="phone" placeholder="Số điện thoại liên hệ" autocomplete="tel" required
               value="<c:out value='${form.phone}'/>">
        <c:if test="${not empty errors.phone}"><div class="a-msg"><c:out value="${errors.phone}"/></div></c:if>
      </div>
      <div class="a-field ${not empty errors.idNumber ? 'bad' : ''}">
        <input class="a-input" type="text" name="idNumber" placeholder="Số CCCD / CMND" inputmode="numeric" required maxlength="12"
               value="<c:out value='${form.idNumber}'/>">
        <c:if test="${not empty errors.idNumber}"><div class="a-msg"><c:out value="${errors.idNumber}"/></div></c:if>
      </div>
      <div class="a-field owner-only ${not empty errors.taxCode ? 'bad' : ''}">
        <input class="a-input" type="text" name="taxCode" placeholder="Mã số thuế (không bắt buộc)" maxlength="50"
               value="<c:out value='${form.taxCode}'/>">
        <c:if test="${not empty errors.taxCode}"><div class="a-msg"><c:out value="${errors.taxCode}"/></div></c:if>
      </div>
      <div class="a-field ${not empty errors.email ? 'bad' : ''}">
        <input class="a-input" type="email" name="email" placeholder="Địa chỉ Email" autocomplete="email" required maxlength="150"
               value="<c:out value='${form.email}'/>">
        <c:if test="${not empty errors.email}"><div class="a-msg"><c:out value="${errors.email}"/></div></c:if>
      </div>
      <div class="a-field ${not empty errors.password ? 'bad' : ''}">
        <input class="a-input" type="password" name="password" placeholder="Mật khẩu (tối thiểu 8 ký tự, có chữ và số)" autocomplete="new-password" required minlength="8">
        <c:if test="${not empty errors.password}"><div class="a-msg"><c:out value="${errors.password}"/></div></c:if>
      </div>
      <div class="a-field ${not empty errors.confirm ? 'bad' : ''}">
        <input class="a-input" type="password" name="confirm" placeholder="Xác nhận lại mật khẩu" autocomplete="new-password" required>
        <div class="a-msg" id="confirmMsg"><c:out value="${errors.confirm}"/></div>
      </div>
      <button class="a-btn" type="submit">Hoàn tất đăng ký</button>
    </form>
    <p class="a-switch">Bạn đã có tài khoản? <a href="${ctx}/login">Đăng nhập ngay</a></p>
    <a class="a-home" href="${ctx}/">← Về trang chủ</a>
  </section>
</main>

<script>
(function () {
  var form = document.getElementById('regForm');
  var ownerOnly = document.querySelector('.owner-only');
  var title = document.getElementById('brandTitle'), text = document.getElementById('brandText');
  var copy = {
    CUSTOMER: ['Tạo tài khoản<br>khách hàng mới', 'Trở thành thành viên để dễ dàng giao dịch, quản lý căn hộ và nhận các tiện ích tốt nhất.'],
    OWNER: ['Tạo tài khoản<br>chủ căn hộ mới', 'Đăng tin bán hoặc cho thuê căn hộ, quản lý lịch xem nhà và khách quan tâm.']
  };
  function sync() {
    var role = form.role.value || 'CUSTOMER';
    ownerOnly.style.display = role === 'OWNER' ? 'block' : 'none';
    title.innerHTML = copy[role][0];
    text.textContent = copy[role][1];
  }
  form.querySelectorAll('input[name=role]').forEach(function (r) { r.addEventListener('change', sync); });
  form.addEventListener('submit', function (e) {          // kiểm tra nhanh; server vẫn kiểm tra lại
    if (form.password.value !== form.confirm.value) {
      e.preventDefault();
      document.getElementById('confirmMsg').textContent = 'Mật khẩu xác nhận không khớp.';
      form.confirm.focus();
    }
  });
  sync();
})();
</script>
</body>
</html>
