<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" session="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title><c:out value="${property.title}"/></title>
  <link rel="stylesheet" href="${ctx}/css/base.css">
  <link rel="stylesheet" href="${ctx}/css/layout.css">
  <link rel="stylesheet" href="${ctx}/css/property-detail.css">
</head>
<body id="top">
<jsp:include page="/WEB-INF/views/partials/header.jsp"/>

<main class="container page">
  <div class="detail">
    <!-- ===== CỘT TRÁI: ảnh, tên + đánh giá, thông số, mô tả, đánh giá chi tiết ===== -->
    <div class="detail__main">
      <section class="gallery">
        <img class="gallery__main" src="<c:url value='${mainImage}'/>" alt="<c:out value="${property.title}"/>">
        <!-- bấm ảnh nhỏ = tải lại trang với ?img=số (không cần JavaScript) -->
        <div class="gallery__thumbs">
          <c:forEach var="it" items="${images}"><a href="<c:out value="${it.href}"/>"><img class="gallery__thumb <c:out value="${it.active}"/>" src="<c:url value='${it.url}'/>" alt=""></a></c:forEach>
        </div>
      </section>

      <h1 class="detail__title"><c:out value="${property.title}"/></h1>
      <p class="detail__meta"><span class="badge">${property.rent ? 'Thuê' : 'Bán'}</span><c:out value="${property.bedrooms}"/> PN · <c:out value="${property.buildingName}"/></p>
      <!-- GIÁ ngay dưới tên: giá chính to + giá/m² (chỉ căn bán) + diện tích -->
      <div class="price-row">
        <strong class="price-row__main"><c:out value="${property.priceText}"/></strong>
        <c:if test="${not property.rent and not empty property.pricePerM2Text}"><span class="price-row__item"><c:out value="${property.pricePerM2Text}"/>/m²</span></c:if>
        <span class="price-row__item"><c:out value="${property.area}"/> m²</span>
      </div>
      <!-- tóm tắt đánh giá ngay dưới giá; bấm vào để cuộn xuống phần #reviews -->
      <a class="rating-line" href="#reviews">
        <c:choose>
          <c:when test="${reviewSummary.count > 0}">
            <span class="stars" aria-hidden="true"><c:out value="${reviewSummary.stars}"/></span>
            <strong><c:out value="${reviewSummary.averageText}"/></strong>
            <span class="rating-line__count">(<c:out value="${reviewSummary.count}"/> đánh giá)</span>
          </c:when>
          <c:otherwise><span class="stars stars--empty" aria-hidden="true">☆☆☆☆☆</span><span class="rating-line__count">Chưa có đánh giá, hãy là người đầu tiên</span></c:otherwise>
        </c:choose>
      </a>
      <p class="detail__address">📍 <c:out value="${property.address}"/>, <c:out value="${property.district}"/>, <c:out value="${property.city}"/> · <c:out value="${property.buildingName}"/></p>

      <section class="card">
        <h2 class="card__title">Thông tin căn hộ</h2>
        <ul class="spec-grid">
          <li>▣ Diện tích: <c:out value="${property.area}"/> m²</li><li>🛏 Phòng ngủ: <c:out value="${property.bedrooms}"/> PN</li>
          <li>🛁 Nhà vệ sinh: <c:out value="${property.bathrooms}"/> WC</li><li>🏠 Tầng: <c:out value="${property.floor}"/></li>
          <li>▥ Ban công: <c:out value="${empty property.direction ? 'Đang cập nhật' : property.direction}"/></li>
          <li>📄 Pháp lý: <c:out value="${property.legalStatus}"/></li>
        </ul>
      </section>

      <section class="card">
        <h2 class="card__title">Mô tả chi tiết</h2>
        <p class="detail__desc"><c:out value="${property.description}"/></p>
      </section>

      <!-- ===== ĐÁNH GIÁ: Controller gửi "reviewSummary", "reviews", "reviewForm", "reviewError", "reviewStatus" ===== -->
      <section class="card" id="reviews">
        <h2 class="card__title">Đánh giá từ khách hàng</h2>

        <div class="review-summary">
          <div class="review-summary__score">
            <p class="review-summary__avg"><c:out value="${reviewSummary.count > 0 ? reviewSummary.averageText : '–'}"/><span>/5</span></p>
            <p class="stars"><c:out value="${reviewSummary.count > 0 ? reviewSummary.stars : '☆☆☆☆☆'}"/></p>
            <p class="review-summary__count"><c:out value="${reviewSummary.count}"/> đánh giá</p>
          </div>
          <ul class="review-bars">
            <c:forEach var="row" items="${reviewSummary.rows}">
            <li class="review-bars__row">
              <span class="review-bars__label"><c:out value="${row.star}"/>★</span>
              <span class="review-bars__track"><span class="review-bars__fill" style="width:${row.percent}%"></span></span>
              <span class="review-bars__num"><c:out value="${row.count}"/></span>
            </li>
            </c:forEach>
          </ul>
        </div>

        <c:if test="${reviewStatus == 'created'}"><p class="alert alert--ok">Cảm ơn bạn! Đánh giá đã được đăng.</p></c:if>
        <c:if test="${reviewStatus == 'updated'}"><p class="alert alert--ok">Đã cập nhật đánh giá trước đó của bạn.</p></c:if>
        <c:if test="${not empty reviewError}"><p class="alert alert--err"><c:out value="${reviewError}"/></p></c:if>

        <!-- FORM: POST /properties/{id}/reviews. Chọn sao bằng radio (không cần JavaScript). -->
        <form class="review-form" method="post" action="${ctx}/properties/${property.propertyId}/reviews#reviews">
          <p class="field__label">Bạn chấm căn hộ này mấy sao?</p>
          <div class="star-input" role="radiogroup" aria-label="Số sao">
            <c:forEach var="s" begin="1" end="5">
              <c:set var="star" value="${6 - s}"/>
              <input type="radio" id="star${star}" name="rating" value="${star}" ${reviewForm.rating == ('' += star) ? 'checked' : ''}>
              <label for="star${star}" title="${star} sao">★</label>
            </c:forEach>
          </div>
          <div class="field-row">
            <label class="field"><span class="field__label">Họ tên</span>
              <input class="input" name="name" maxlength="40" required value="<c:out value="${reviewForm.name}"/>"></label>
            <label class="field"><span class="field__label">Email</span>
              <input class="input" type="email" name="email" maxlength="100" required value="<c:out value="${reviewForm.email}"/>"></label>
          </div>
          <label class="field"><span class="field__label">Nhận xét</span>
            <textarea class="input textarea" name="comment" maxlength="1000" required placeholder="Vị trí, tiện ích, chủ nhà, giá cả..."><c:out value="${reviewForm.comment}"/></textarea></label>
          <p class="review-form__hint">Mỗi email chỉ có 1 đánh giá cho mỗi căn; gửi lại sẽ cập nhật đánh giá cũ.</p>
          <button class="btn btn--primary" type="submit">Gửi đánh giá</button>
        </form>

        <ul class="review-list">
          <c:forEach var="r" items="${reviews}">
          <li class="review">
            <span class="review__avatar" aria-hidden="true"><c:out value="${r.initial}"/></span>
            <div class="review__body">
              <p class="review__head"><strong><c:out value="${r.reviewerName}"/></strong><span class="review__date"><c:out value="${r.dateText}"/></span></p>
              <p class="stars stars--sm"><c:out value="${r.stars}"/></p>
              <p class="review__text"><c:out value="${r.comment}"/></p>
            </div>
          </li>
          </c:forEach>
          <c:if test="${empty reviews}"><li class="review-list__empty">Chưa có đánh giá nào cho căn hộ này.</li></c:if>
        </ul>
      </section>
    </div>

    <!-- ===== CỘT PHẢI (dính khi cuộn): chủ sở hữu, nút hành động ===== -->
    <aside class="detail__side">
      <!-- CHỦ SỞ HỮU: Controller gửi "owner" (Owner kế thừa User) và "ownerListings" -->
      <div class="owner-card">
        <div class="owner-card__banner"><span class="owner-card__label">Chủ sở hữu</span></div>
        <c:choose>
          <c:when test="${not empty owner}">
            <div class="owner-card__body">
              <span class="owner-card__avatar" aria-hidden="true"><c:out value="${owner.initial}"/></span>
              <p class="owner-card__name"><c:out value="${owner.username}"/></p>
              <ul class="owner-card__stats">
                <li><b><c:out value="${ownerListings}"/></b><span>tin đang đăng</span></li>
                <li><b><c:out value="${owner.memberSince}"/></b><span>thành viên từ</span></li>
              </ul>
              <c:choose>
                <c:when test="${not empty owner.phone}">
                  <a class="owner-card__phone" href="tel:<c:out value="${owner.phone}"/>"><span aria-hidden="true">📞</span><c:out value="${owner.phoneText}"/></a>
                </c:when>
                <c:otherwise><span class="owner-card__phone is-empty">Chưa cập nhật số điện thoại</span></c:otherwise>
              </c:choose>
            </div>
          </c:when>
          <c:otherwise><p class="owner-card__body owner-card__none">Chưa có thông tin chủ sở hữu cho căn này.</p></c:otherwise>
        </c:choose>
      </div>

      <div class="detail__actions">
        <a class="btn btn--primary" href="${ctx}/appointments?propertyId=${property.propertyId}">Đặt lịch xem nhà</a>
        <form method="post" action="${ctx}/comparisons" style="display:contents">
          <input type="hidden" name="action" value="add"><input type="hidden" name="id" value="<c:out value="${property.propertyId}"/>">
          <button class="btn btn--outline" type="submit">Thêm vào so sánh</button>
        </form>
      </div>
    </aside>
  </div>

  <!-- PHẦN 1 - CÙNG QUẬN: Controller gửi "sameDistrict" (cùng loại Bán/Thuê, cùng quận, giá & diện tích gần) -->
  <c:if test="${not empty sameDistrict}">
  <section class="similar">
    <div class="similar__head">
      <h2 class="similar__title">Căn hộ tương tự tại <c:out value="${property.district}"/></h2>
      <c:url var="moreUrl" value="/properties"><c:param name="type" value="${property.rent ? 'RENT' : 'SALE'}"/><c:param name="district" value="${property.district}"/></c:url>
      <a class="similar__more" href="${moreUrl}">Xem tất cả →</a>
    </div>
    <div class="similar__grid">
      <c:forEach var="it" items="${sameDistrict}">
        <c:set var="card" value="${it}" scope="request"/>
        <jsp:include page="/WEB-INF/views/partials/similar-card.jsp"/>
      </c:forEach>
    </div>
  </section>
  </c:if>

  <!-- PHẦN 2 - KHU VỰC KHÁC: Controller gửi "otherDistrict" (quận khác nhưng giá & diện tích gần) -->
  <c:if test="${not empty otherDistrict}">
  <section class="similar">
    <div class="similar__head">
      <h2 class="similar__title">Gợi ý ở khu vực khác</h2>
      <span class="similar__note">Mức giá và diện tích tương đương</span>
    </div>
    <div class="similar__grid">
      <c:forEach var="it" items="${otherDistrict}">
        <c:set var="card" value="${it}" scope="request"/>
        <jsp:include page="/WEB-INF/views/partials/similar-card.jsp"/>
      </c:forEach>
    </div>
  </section>
  </c:if>
</main>

<jsp:include page="/WEB-INF/views/partials/footer.jsp"/>
</body>
</html>
