<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" session="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Đặt lịch xem căn hộ</title>
  <link rel="stylesheet" href="${ctx}/css/base.css">
  <link rel="stylesheet" href="${ctx}/css/layout.css">
  <link rel="stylesheet" href="${ctx}/css/appointment.css">
</head>
<body id="top">
<jsp:include page="/WEB-INF/views/partials/header.jsp"/>

<main class="container page appt">
  <p class="appt-breadcrumb"><a href="${ctx}/">Trang chủ</a> / <a href="${ctx}/properties">Căn hộ</a> / <strong>Đặt lịch xem nhà</strong></p>
  <h1 class="page__title">Đặt lịch xem căn hộ</h1>
  <p class="appt-sub">Chọn thời gian phù hợp và để chúng tôi giúp bạn khám phá ngôi nhà tương lai.</p>

  <c:if test="${not empty booked}">
    <div class="alert alert--ok">✓ <b>Đặt lịch thành công!</b> Mã lịch hẹn #<c:out value="${booked.id}"/> —
      <c:out value="${booked.dateText}"/> lúc <c:out value="${booked.time}"/>. Nhân viên sẽ liên hệ để xác nhận.</div>
  </c:if>
  <c:if test="${not empty error}">
    <div class="alert alert--err">⚠ <c:out value="${error}"/></div>
  </c:if>

  <div class="appt-layout">
    <section class="appt-card">
      <div class="appt-step"><span class="appt-step__no">01</span>
        <div><h2>Chọn ngày &amp; giờ xem</h2><p>Vui lòng chọn một khung giờ còn trống.</p></div></div>

      <div class="cal-head">
        <h3><c:out value="${monthTitle}"/></h3>
        <div class="cal-nav">
          <c:choose>
            <c:when test="${empty prevHref}"><span class="cal-nav__btn is-disabled">‹</span></c:when>
            <c:otherwise><a class="cal-nav__btn" href="<c:out value='${prevHref}'/>">‹</a></c:otherwise>
          </c:choose>
          <c:choose>
            <c:when test="${empty nextHref}"><span class="cal-nav__btn is-disabled">›</span></c:when>
            <c:otherwise><a class="cal-nav__btn" href="<c:out value='${nextHref}'/>">›</a></c:otherwise>
          </c:choose>
        </div>
      </div>

      <div class="cal-grid">
        <div class="cal-dow">T2</div><div class="cal-dow">T3</div><div class="cal-dow">T4</div><div class="cal-dow">T5</div>
        <div class="cal-dow">T6</div><div class="cal-dow">T7</div><div class="cal-dow">CN</div>
        <c:forEach var="cell" items="${cells}">
          <c:choose>
            <c:when test="${cell.blank}"><div></div></c:when>
            <c:when test="${empty cell.href}"><span class="cal-day ${cell.cls}"><b>${cell.day}</b><small>${cell.label}</small></span></c:when>
            <c:otherwise><a class="cal-day ${cell.cls}" href="<c:out value='${cell.href}'/>"><b>${cell.day}</b><small>${cell.label}</small></a></c:otherwise>
          </c:choose>
        </c:forEach>
      </div>

      <h3 class="slot-title">Khung giờ có sẵn <span>· <c:out value="${dateText}"/></span></h3>
      <div class="slot-grid">
        <c:forEach var="slot" items="${slots}">
          <c:choose>
            <c:when test="${empty slot.href}"><span class="slot ${slot.cls}">${slot.time}</span></c:when>
            <c:otherwise><a class="slot ${slot.cls}" href="<c:out value='${slot.href}'/>">${slot.time}</a></c:otherwise>
          </c:choose>
        </c:forEach>
      </div>

      <hr class="appt-hr">
      <form method="post" action="${ctx}/appointments">
        <input type="hidden" name="propertyId" value="${property.propertyId}">
        <input type="hidden" name="date" value="<c:out value='${selectedDate}'/>">
        <input type="hidden" name="time" value="<c:out value='${selectedTime}'/>">

        <div class="appt-step"><span class="appt-step__no">02</span>
          <div><h2>Thông tin liên hệ</h2><p>Nhân viên tư vấn sẽ xác nhận lịch với bạn.</p></div></div>

        <div class="field-row">
          <div class="field"><label class="field__label" for="fullName">Họ và tên *</label>
            <input class="input" id="fullName" name="fullName" maxlength="100" required placeholder="Nguyễn Văn A" value="<c:out value='${form.fullName}'/>"></div>
          <div class="field"><label class="field__label" for="phone">Số điện thoại *</label>
            <input class="input" id="phone" name="phone" maxlength="20" required placeholder="09xx xxx xxx" value="<c:out value='${form.phone}'/>"></div>
        </div>
        <div class="field-row">
          <div class="field"><label class="field__label" for="email">Email</label>
            <input class="input" id="email" name="email" type="email" maxlength="100" placeholder="ban@email.com" value="<c:out value='${form.email}'/>"></div>
          <div class="field"><label class="field__label" for="attendees">Số người tham gia</label>
            <select class="input" id="attendees" name="attendees">
              <option value="1" ${form.attendees == '1' ? 'selected' : ''}>1 người</option>
              <option value="2" ${form.attendees == '2' ? 'selected' : ''}>2 người</option>
              <option value="3" ${form.attendees == '3' ? 'selected' : ''}>3 người</option>
              <option value="4" ${form.attendees == '4' ? 'selected' : ''}>4 người</option>
              <option value="5" ${form.attendees == '5' ? 'selected' : ''}>5 người</option>
            </select></div>
        </div>
        <div class="field"><label class="field__label" for="note">Ghi chú <small>(không bắt buộc)</small></label>
          <textarea class="input textarea" id="note" name="note" maxlength="500" placeholder="Ví dụ: Tôi muốn tìm hiểu thêm về phí quản lý..."><c:out value="${form.note}"/></textarea></div>

        <button class="btn btn--primary btn--block appt-submit" type="submit" ${empty selectedTime ? 'disabled' : ''}>Xác nhận lịch xem nhà</button>
        <c:if test="${empty selectedTime}"><p class="appt-hint">Hãy chọn một khung giờ ở trên để tiếp tục.</p></c:if>
        <p class="appt-privacy">Thông tin của bạn được bảo mật và chỉ dùng để xác nhận lịch hẹn.</p>
      </form>
    </section>

    <aside class="appt-side">
      <div class="appt-card appt-prop">
        <div class="appt-prop__img"><img src="<c:url value='${property.thumbnailUrl}'/>" alt="<c:out value='${property.title}'/>">
          <span class="appt-prop__badge">Căn hộ nổi bật</span></div>
        <h3 class="appt-prop__title"><c:out value="${property.title}"/></h3>
        <p class="appt-prop__loc">📍 <c:out value="${property.district}"/>, <c:out value="${property.city}"/></p>
        <p class="appt-prop__price"><c:out value="${property.priceText}"/> <small>Giá bán</small></p>
        <div class="appt-prop__specs">
          <div><b>${property.bedrooms}</b><small>Phòng ngủ</small></div>
          <div><b>${property.bathrooms}</b><small>Phòng tắm</small></div>
          <div><b><c:out value="${property.area}"/> m²</b><small>Diện tích</small></div>
        </div>
        <div class="appt-agent"><span class="appt-agent__avatar">ML</span>
          <div><b>Minh Linh</b><small>Chuyên viên tư vấn bất động sản</small></div></div>
        <div class="appt-summary">
          <h4>Tóm tắt lịch hẹn</h4>
          <p><span>Ngày xem</span><b><c:out value="${dateText}"/></b></p>
          <p><span>Giờ xem</span><b><c:out value="${timeText}"/></b></p>
          <p><span>Thời lượng</span><b>Khoảng 30 phút</b></p>
        </div>
        <p class="appt-perks">✓ Miễn phí tham quan · Không bắt buộc đặt cọc · Nhân viên sẽ liên hệ xác nhận.</p>
      </div>
    </aside>
  </div>
</main>

<jsp:include page="/WEB-INF/views/partials/footer.jsp"/>
</body>
</html>
