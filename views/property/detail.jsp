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
      <div class="detail__map">Bản đồ vị trí</div>
    </section>
  </div>
</main>

<jsp:include page="/WEB-INF/views/partials/footer.jsp"/>
</body>
</html>
