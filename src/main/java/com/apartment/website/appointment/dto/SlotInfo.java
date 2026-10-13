package com.apartment.website.appointment.dto;

/** Một khung giờ trong ngày và còn trống hay không. */
public record SlotInfo(String time, boolean available) {}
