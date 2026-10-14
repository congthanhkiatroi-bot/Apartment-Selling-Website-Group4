package com.apartment.website.interaction.dto;

import java.util.List;
import java.util.Locale;

/**
 * Tổng hợp đánh giá của 1 căn: điểm trung bình, số lượt, và số lượt theo từng mức sao (để vẽ thanh 5★ ... 1★).
 * Class có getter (không dùng record) vì EL của Tomcat 10.1 chưa đọc được field của record.
 */
public class ReviewSummary {
    private final double average; private final int count; private final List<StarRow> rows;

    public ReviewSummary(double average, int count, List<StarRow> rows) {
        this.average = average; this.count = count; this.rows = rows;
    }

    public double getAverage() { return average; }   public int getCount() { return count; }
    public List<StarRow> getRows() { return rows; }
    /** 4.666 -> "4.7" */
    public String getAverageText() { return String.format(Locale.US, "%.1f", average); }
    /** Làm tròn điểm trung bình thành chuỗi sao: 4.3 -> "★★★★☆" */
    public String getStars() { int full = (int) Math.round(average); return "★".repeat(full) + "☆".repeat(5 - full); }

    /** 1 dòng "5★ ▓▓▓▓░ 3": star = số sao, count = số lượt, percent = độ dài thanh (0-100). */
    public static class StarRow {
        private final int star, count, percent;
        public StarRow(int star, int count, int percent) { this.star = star; this.count = count; this.percent = percent; }
        public int getStar() { return star; }  public int getCount() { return count; }  public int getPercent() { return percent; }
    }
}
