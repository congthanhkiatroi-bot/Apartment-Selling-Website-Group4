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
    <section class="gallery">
      <img class="gallery__main" src="<c:url value='${mainImage}'/>" alt="<c:out value="${property.title}"/>">
      <!-- bấm ảnh nhỏ = tải lại trang với ?img=số (không cần JavaScript) -->
      <div class="gallery__thumbs">
        <c:forEach var="it" items="${images}"><a href="<c:out value="${it.href}"/>"><img class="gallery__thumb <c:out value="${it.active}"/>" src="<c:url value='${it.url}'/>" alt=""></a></c:forEach>
      </div>
    </section>

    <section class="detail__info">
      <h1 class="detail__title"><c:out value="${property.title}"/></h1>
      <div class="price-card">
        <span class="badge">${property.rent ? 'Thuê' : 'Bán'}</span>
        <p class="price-card__price"><c:out value="${property.priceText}"/></p>
        <ul class="spec-grid">
          <li>▣ Diện tích: <c:out value="${property.area}"/> m²</li><li>🛏 Phòng ngủ: <c:out value="${property.bedrooms}"/> PN</li>
          <li>🛁 Nhà vệ sinh: <c:out value="${property.bathrooms}"/> WC</li><li>🏠 Tầng: <c:out value="${property.floor}"/></li>
          <li class="spec-grid__item--full">▥ Ban công: <c:out value="${property.direction}"/></li>
          <li class="spec-grid__item--full">📄 Pháp lý: <c:out value="${property.legalStatus}"/></li>
        </ul>
      </div>
      <h2 class="detail__desc-title">Mô tả chi tiết</h2>
      <p class="detail__desc" style="white-space:pre-line"><c:out value="${property.description}"/></p>
      <p class="detail__desc">📍 <c:out value="${property.address}"/>, <c:out value="${property.district}"/>, <c:out value="${property.city}"/> · <c:out value="${property.buildingName}"/></p>
      <div class="detail__actions">
        <a class="btn btn--primary" href="${ctx}/appointments?propertyId=${property.propertyId}">Đặt lịch xem nhà</a>
        <form method="post" action="${ctx}/comparisons" style="display:contents">
          <input type="hidden" name="action" value="add"><input type="hidden" name="id" value="<c:out value="${property.propertyId}"/>">
          <button class="btn btn--outline" type="submit" style="cursor:pointer">Thêm vào so sánh</button>
        </form>
      </div>

    </section>
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
