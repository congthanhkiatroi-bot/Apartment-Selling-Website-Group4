package com.apartment.website.property.entity;

import com.apartment.website.listing.entity.Posting;
import com.apartment.website.interaction.entity.Comment;
import com.apartment.website.interaction.entity.ComparisonItem;
import com.apartment.website.interaction.entity.Favorite;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "PROPERTIES")
public class Property {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PROPERTY_ID")
    private Long propertyId;

    @Column(name = "PRICE", nullable = false, precision = 15, scale = 2)
    private BigDecimal price;

    @Column(name = "AREA", nullable = false)
    private Double area;

    @Column(name = "BEDROOMS", nullable = false)
    private Integer bedrooms;

    @Column(name = "BATHROOMS", nullable = false)
    private Integer bathrooms;

    @Column(name = "FLOOR")
    private Integer floor;

    @Column(name = "ADDRESS", nullable = false, length = 500)
    private String address;

    @Column(name = "CITY", nullable = false, length = 100)
    private String city;

    @Column(name = "DISTRICT", length = 100)
    private String district;

    @Column(name = "WARD", length = 100)
    private String ward;

    @Enumerated(EnumType.STRING)
    @Column(name = "PROPERTY_TYPE", nullable = false, length = 30)
    private PropertyType propertyType;

    @Enumerated(EnumType.STRING)
    @Column(name = "STATUS", nullable = false, length = 30)
    private PropertyStatus status;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @ManyToMany
    @JoinTable(
            name = "PROPERTY_AMENITIES",
            joinColumns = @JoinColumn(name = "PROPERTY_ID"),
            inverseJoinColumns = @JoinColumn(name = "AMENITY_ID")
    )
    private List<Amenity> amenities = new ArrayList<>();

    @OneToMany(
            mappedBy = "property",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    @OrderBy("displayOrder ASC")
    private List<PropertyImage> images = new ArrayList<>();

    public List<PropertyImage> getImages() {
        return images;
    }

    public void setImages(List<PropertyImage> images) {
        this.images = images;
    }

    public void addImage(PropertyImage image) {

        if (image == null) {
            throw new IllegalArgumentException(
                    "Property image cannot be null."
            );
        }

        images.add(image);
        image.setProperty(this);
    }

    public void removeImage(PropertyImage image) {

        if (image != null && images.remove(image)) {
            image.setProperty(null);
        }
    }
    @OneToMany(
            mappedBy = "property"
    )
    private List<Posting> postings =
            new ArrayList<>();
    public List<Posting> getPostings() {
        return postings;
    }

    public void setPostings(
            List<Posting> postings
    ) {
        this.postings = postings;
    }
    @OneToMany(
            mappedBy = "property",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<Comment> comments = new ArrayList<>();

    @OneToMany(
            mappedBy = "property",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<Favorite> favorites = new ArrayList<>();

    @OneToMany(
            mappedBy = "property",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<ComparisonItem> comparisonItems = new ArrayList<>();

    public Property() {
        this.createdAt = LocalDateTime.now();
        this.status = PropertyStatus.AVAILABLE;
    }

    public Property(
            BigDecimal price,
            Double area,
            Integer bedrooms,
            Integer bathrooms,
            Integer floor,
            String address,
            String city,
            String district,
            String ward,
            PropertyType propertyType
    ) {
        this.price = price;
        this.area = area;
        this.bedrooms = bedrooms;
        this.bathrooms = bathrooms;
        this.floor = floor;
        this.address = address;
        this.city = city;
        this.district = district;
        this.ward = ward;
        this.propertyType = propertyType;
        this.status = PropertyStatus.AVAILABLE;
        this.createdAt = LocalDateTime.now();
    }

    public void addAmenity(Amenity amenity) {
        if (amenity != null && !amenities.contains(amenity)) {
            amenities.add(amenity);
        }
    }

    public void removeAmenity(Amenity amenity) {
        amenities.remove(amenity);
    }

    public void markAsReserved() {
        this.status = PropertyStatus.RESERVED;
    }

    public void markAsSold() {
        this.status = PropertyStatus.SOLD;
    }

    public void markAsAvailable() {
        this.status = PropertyStatus.AVAILABLE;
    }

    public boolean isAvailable() {
        return this.status == PropertyStatus.AVAILABLE;
    }

    public Long getPropertyId() {
        return propertyId;
    }

    public void setPropertyId(Long propertyId) {
        this.propertyId = propertyId;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public Double getArea() {
        return area;
    }

    public void setArea(Double area) {
        this.area = area;
    }

    public Integer getBedrooms() {
        return bedrooms;
    }

    public void setBedrooms(Integer bedrooms) {
        this.bedrooms = bedrooms;
    }

    public Integer getBathrooms() {
        return bathrooms;
    }

    public void setBathrooms(Integer bathrooms) {
        this.bathrooms = bathrooms;
    }

    public Integer getFloor() {
        return floor;
    }

    public void setFloor(Integer floor) {
        this.floor = floor;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getWard() {
        return ward;
    }

    public void setWard(String ward) {
        this.ward = ward;
    }

    public PropertyType getPropertyType() {
        return propertyType;
    }

    public void setPropertyType(PropertyType propertyType) {
        this.propertyType = propertyType;
    }

    public PropertyStatus getStatus() {
        return status;
    }

    public void setStatus(PropertyStatus status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public List<Amenity> getAmenities() {
        return amenities;
    }

    public void setAmenities(List<Amenity> amenities) {
        this.amenities = amenities;
    }

    public List<Comment> getComments() {
        return comments;
    }

    public void setComments(List<Comment> comments) {
        this.comments = comments;
    }

    public List<Favorite> getFavorites() {
        return favorites;
    }

    public void setFavorites(List<Favorite> favorites) {
        this.favorites = favorites;
    }

    public List<ComparisonItem> getComparisonItems() {
        return comparisonItems;
    }

    public void setComparisonItems(List<ComparisonItem> comparisonItems) {
        this.comparisonItems = comparisonItems;
    }

    public enum PropertyType {
        APARTMENT,
        STUDIO,
        PENTHOUSE,
        OFFICETEL
    }

    public enum PropertyStatus {
        AVAILABLE,
        RESERVED,
        SOLD
    }
}