package com.apartment.website.property.dto;

import java.util.List;

/** Một trang kết quả + tổng số bản ghi (để vẽ phân trang). */
public class PageResult<T> {
    private final List<T> items;
    private final long total;
    private final int page;
    private final int size;

    public PageResult(List<T> items, long total, int page, int size) {
        this.items = items;
        this.total = total;
        this.page = page;
        this.size = size;
    }

    public List<T> getItems() {
        return items;
    }

    public long getTotal() {
        return total;
    }

    public int getPage() {
        return page;
    }

    public int getSize() {
        return size;
    }

    /** Số trang = làm tròn lên (total / size), ít nhất là 1 trang. */
    public int getTotalPages() {
        long pages = (total + size - 1) / size;
        if (pages < 1) {
            return 1;
        }
        return (int) pages;
    }
}
