<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" session="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Về chúng tôi | Apartment Website</title>
  <link rel="stylesheet" href="${ctx}/css/base.css?v=6">
  <link rel="stylesheet" href="${ctx}/css/layout.css?v=6">
  <link rel="stylesheet" href="${ctx}/css/about.css?v=3">
</head>
<body id="top">
<jsp:include page="/WEB-INF/views/partials/header.jsp"/>

<%-- Dữ liệu do AboutServlet gửi sang:
     - ${stats}: các con số đếm thật từ database (SiteStats)
     - ${districts}: danh sách quận có căn hộ
     Các nút trong trang:
     - link tới trang khác (${ctx}/properties, ${ctx}/comparisons, ...)
     - link "#contact", "#top": nhảy tới phần tương ứng trong cùng trang
     - <details><summary>: bấm để mở / đóng câu hỏi, không cần JavaScript --%>

<!-- ================= HERO ================= -->
<section class="about-hero">
  <div class="about-hero__overlay"></div>
  <div class="container about-hero__content">
    <span class="about-badge">VỀ APARTMENT WEBSITE</span>
    <h1>Nền tảng mua bán &amp; cho thuê căn hộ uy tín hàng đầu Việt Nam</h1>
    <p>Apartment Website giúp mọi gia đình tìm được tổ ấm phù hợp: thông tin minh bạch,
      tin đăng được rà soát và đặt lịch xem nhà chỉ trong vài cú nhấp chuột.</p>
    <div class="about-hero__actions">
      <a href="${ctx}/properties" class="btn btn--primary">Tìm căn hộ ngay</a>
      <a href="#contact" class="btn about-btn--ghost">Liên hệ với chúng tôi</a>
    </div>
  </div>
</section>

<!-- ================= CON SỐ (đếm thật từ database) ================= -->
<section class="about-stats-wrap"><div class="container about-stats-bar">
  <a href="${ctx}/properties" class="about-stat about-stat--link">
    <strong>${stats.saleCount}</strong><span>Căn hộ đang bán</span>
  </a>
  <a href="${ctx}/properties?type=RENT" class="about-stat about-stat--link">
    <strong>${stats.rentCount}</strong><span>Căn hộ cho thuê</span>
  </a>
  <div class="about-stat"><strong>${stats.buildingCount}</strong><span>Tòa nhà &amp; dự án</span></div>
  <div class="about-stat"><strong>${stats.districtCount}</strong><span>Quận / khu vực</span></div>
  <div class="about-stat"><strong>${stats.userCount}</strong><span>Người dùng</span></div>
  <div class="about-stat"><strong>${stats.viewingCount}</strong><span>Lượt hẹn xem nhà</span></div>
</div></section>

<main>
  <!-- ================= CHÚNG TÔI LÀ AI ================= -->
  <section class="about-section about-section--white">
    <div class="container about-mission">
      <div>
        <span class="about-label">CHÚNG TÔI LÀ AI</span>
        <h2>Kênh căn hộ minh bạch, đáng tin cậy cho mọi người</h2>
        <p class="about-lead">Người mua thường phải xem nhiều trang, gọi nhiều cuộc điện thoại mới hẹn được một buổi xem nhà.
          Apartment Website gom tất cả vào một chỗ: tìm kiếm, so sánh, đặt lịch và nhận thông báo,
          để việc mua hay thuê căn hộ trở nên đơn giản và an tâm.</p>
        <div class="about-values">
          <div class="about-value"><span>✓</span><div><strong>Tin đăng được rà soát</strong><p>Quản trị viên thường xuyên rà soát tin đăng, tin sai mô tả sẽ bị gỡ khỏi hệ thống.</p></div></div>
          <div class="about-value"><span>✓</span><div><strong>Pháp lý rõ ràng</strong><p>Tình trạng pháp lý (sổ hồng, hợp đồng thuê, ...) được ghi rõ trên từng căn hộ.</p></div></div>
          <div class="about-value"><span>✓</span><div><strong>Kết nối trực tiếp</strong><p>Người mua làm việc thẳng với chủ căn hộ, không qua trung gian.</p></div></div>
        </div>
      </div>
      <div class="about-stat-card">
        <div class="about-stat-card__icon">⌂</div>
        <h3>Apartment Website</h3>
        <p>Nơi kết nối người mua, người thuê và chủ căn hộ trên khắp thành phố.</p>
        <div class="about-stats">
          <div><strong>${stats.apartmentCount}</strong><span>Căn đang giao dịch</span></div>
          <div><strong>${stats.ownerCount}</strong><span>Chủ căn hộ</span></div>
          <div><strong>24/7</strong><span>Truy cập</span></div>
        </div>
      </div>
    </div>
  </section>

  <!-- ================= VÌ SAO CHỌN CHÚNG TÔI ================= -->
  <section class="about-section">
    <div class="container">
      <div class="about-heading">
        <span class="about-label">VÌ SAO CHỌN CHÚNG TÔI</span>
        <h2>Những điều làm nên sự khác biệt</h2>
        <p>Mọi tính năng đều hướng tới một mục tiêu: giúp bạn ra quyết định nhanh và chính xác.</p>
      </div>
      <div class="feature-grid">
        <div class="feature-card">
          <div class="feature-card__icon">🛡️</div>
          <h3>Tin thật, căn thật</h3>
          <p>Quản trị viên rà soát tin đăng; tin sai mô tả sẽ bị gỡ.</p>
          <a href="${ctx}/properties" class="about-link">Xem căn hộ →</a>
        </div>
        <div class="feature-card">
          <div class="feature-card__icon">🔍</div>
          <h3>Tìm kiếm thông minh</h3>
          <p>Lọc theo quận, mức giá, số phòng ngủ, hình thức bán hoặc thuê.</p>
          <a href="${ctx}/properties?price=under2" class="about-link">Căn dưới 2 tỷ →</a>
        </div>
        <div class="feature-card">
          <div class="feature-card__icon">⚖️</div>
          <h3>So sánh trực quan</h3>
          <p>Đặt tối đa 3 căn cạnh nhau để so giá, diện tích và tiện ích.</p>
          <a href="${ctx}/comparisons" class="about-link">Mở so sánh →</a>
        </div>
        <div class="feature-card">
          <div class="feature-card__icon">📅</div>
          <h3>Đặt lịch xem nhà</h3>
          <p>Chọn khung giờ trống, chủ căn hộ xác nhận và bạn nhận thông báo ngay.</p>
          <%-- đã đăng nhập (khách / chủ) -> xem lịch hẹn; chưa đăng nhập -> đăng nhập --%>
          <a href="${ctx}${currentUser.owner or currentUser.customer ? '/viewings' : '/auth?action=login'}" class="about-link">
            ${currentUser.owner or currentUser.customer ? 'Lịch hẹn của tôi →' : 'Đăng nhập để đặt lịch →'}</a>
        </div>
      </div>
    </div>
  </section>

  <!-- ================= KHU VỰC ================= -->
  <section class="about-section about-section--white">
    <div class="container">
      <div class="about-heading">
        <span class="about-label">KHU VỰC HOẠT ĐỘNG</span>
        <h2>Có mặt tại ${stats.districtCount} quận / khu vực</h2>
        <p>Bấm vào một khu vực để xem các căn hộ đang bán ở đó.</p>
      </div>
      <div class="district-list">
        <c:forEach var="d" items="${districts}">
          <%-- c:url + c:param tự mã hóa tên quận có dấu / khoảng trắng trên URL --%>
          <a class="district-chip" href="<c:url value='/properties'><c:param name='district' value='${d}'/></c:url>">📍 <c:out value="${d}"/></a>
        </c:forEach>
      </div>
    </div>
  </section>

  <!-- ================= CÁCH HOẠT ĐỘNG ================= -->
  <section class="about-section">
    <div class="container">
      <div class="about-heading">
        <span class="about-label">CÁCH HOẠT ĐỘNG</span>
        <h2>3 bước để tìm được căn hộ</h2>
      </div>
      <div class="step-grid">
        <div class="step-card"><span class="step-card__no">01</span><h3>Tìm căn hộ</h3>
          <p>Lọc theo khu vực, giá và số phòng ngủ.</p>
          <a href="${ctx}/properties" class="about-link">Tìm ngay →</a></div>
        <div class="step-card"><span class="step-card__no">02</span><h3>So sánh</h3>
          <p>Đặt các căn hộ cạnh nhau để chọn căn phù hợp nhất.</p>
          <a href="${ctx}/comparisons" class="about-link">Mở so sánh →</a></div>
        <div class="step-card"><span class="step-card__no">03</span><h3>Đặt lịch xem</h3>
          <p>Chọn khung giờ trống ở trang chi tiết, chờ chủ căn hộ xác nhận.</p>
          <a href="${ctx}${currentUser.owner or currentUser.customer ? '/viewings' : '/auth?action=login'}" class="about-link">
            ${currentUser.owner or currentUser.customer ? 'Xem lịch hẹn →' : 'Đăng nhập để đặt lịch →'}</a></div>
      </div>
    </div>
  </section>

  <!-- ================= DÀNH CHO AI ================= -->
  <section class="about-section about-section--white">
    <div class="container audience-grid">
      <div class="audience-card">
        <span class="about-label">NGƯỜI MUA &amp; NGƯỜI THUÊ</span>
        <h3>Tìm tổ ấm phù hợp với bạn</h3>
        <p>Xem căn hộ có hình ảnh thật, so sánh và đặt lịch xem hoàn toàn miễn phí.</p>
        <div class="audience-card__actions">
          <a href="${ctx}/properties" class="btn btn--primary">Căn hộ đang bán</a>
          <a href="${ctx}/properties?type=RENT" class="btn btn--outline">Căn hộ cho thuê</a>
        </div>
      </div>
      <div class="audience-card audience-card--green">
        <span class="about-label">CHỦ CĂN HỘ</span>
        <h3>Tiếp cận đúng khách hàng</h3>
        <p>Đăng tin bán hoặc cho thuê, nhận lịch hẹn xem nhà và quản lý tin đăng ngay trên web.</p>
        <%-- Nút đổi theo vai trò, giống service-card "Đăng tin" ở trang chủ --%>
        <div class="audience-card__actions">
          <a href="${ctx}${currentUser.owner ? '/postings?action=create' : '/auth?action=register&role=OWNER'}" class="btn about-btn--white">
            ${currentUser.owner ? 'Đăng tin ngay' : 'Đăng ký chủ căn hộ'}</a>
        </div>
      </div>
    </div>
  </section>

  <!-- ================= LIÊN HỆ ================= -->
  <section class="about-section" id="contact">
    <div class="container about-contact">
      <div class="contact-card">
        <span class="about-label">LIÊN HỆ</span>
        <h2>Chúng tôi luôn sẵn sàng hỗ trợ</h2>
        <ul class="contact-list">
          <li><span>📍</span><div><strong>Địa chỉ</strong><p>1 Võ Văn Ngân, Thủ Đức, TP. Hồ Chí Minh</p></div></li>
          <li><span>🕘</span><div><strong>Thời gian hỗ trợ</strong><p>Thứ 2 - Thứ 6, 8:00 - 17:00</p></div></li>
          <li><span>🏫</span><div><strong>Đơn vị phát triển</strong><p>Nhóm 4, Khoa Công nghệ Thông tin, Trường Đại học Công nghệ Kỹ thuật TP.HCM</p></div></li>
        </ul>
        <div class="contact-actions">
          <a href="${ctx}/properties" class="btn btn--primary">Tìm căn hộ</a>
          <c:if test="${empty currentUser}">
            <a href="${ctx}/auth?action=register" class="btn btn--outline">Tạo tài khoản</a>
          </c:if>
        </div>
      </div>

      <div class="faq">
        <h3>Câu hỏi thường gặp</h3>
        <details class="faq__item" open>
          <summary>Tôi có cần tài khoản để xem căn hộ không?</summary>
          <p>Không. Ai cũng xem được danh sách và chi tiết căn hộ. Chỉ khi đặt lịch xem nhà mới cần đăng nhập.</p>
        </details>
        <details class="faq__item">
          <summary>Làm sao để đăng tin bán / cho thuê?</summary>
          <p>Đăng ký tài khoản với vai trò Chủ căn hộ, sau đó vào mục "Đăng tin" trên thanh menu.</p>
        </details>
        <details class="faq__item">
          <summary>Tin đăng có được kiểm tra không?</summary>
          <p>Có. Quản trị viên rà soát các tin đã đăng; tin sai mô tả sẽ bị gỡ và chủ căn hộ nhận được thông báo.</p>
        </details>
        <details class="faq__item">
          <summary>Đặt lịch xong thì bao giờ được xác nhận?</summary>
          <p>Chủ căn hộ nhận thông báo ngay. Khi họ xác nhận hoặc từ chối, bạn sẽ thấy ở biểu tượng 🔔 và trang Lịch hẹn.</p>
        </details>
        <details class="faq__item">
          <summary>So sánh được tối đa bao nhiêu căn?</summary>
          <p>Tối đa 3 căn cùng lúc. Bấm "So sánh" ở các căn hộ bạn quan tâm, rồi mở mục "So sánh" trên menu để xem chúng cạnh nhau.</p>
        </details>
      </div>
    </div>
  </section>

  <div class="container about-top"><a href="#top">↑ Lên đầu trang</a></div>
</main>

<jsp:include page="/WEB-INF/views/partials/footer.jsp"/>
</body>
</html>
