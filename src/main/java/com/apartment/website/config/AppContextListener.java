package com.apartment.website.config;

import com.apartment.website.appointment.repository.AppointmentRepository;
import com.apartment.website.appointment.repository.AppointmentRepositoryJdbc;
import com.apartment.website.appointment.service.AppointmentService;
import com.apartment.website.interaction.repository.ReviewRepository;
import com.apartment.website.interaction.repository.ReviewRepositoryJdbc;
import com.apartment.website.interaction.service.ReviewService;
import com.apartment.website.property.repository.PropertyRepository;
import com.apartment.website.property.repository.PropertyRepositoryJdbc;
import com.apartment.website.property.service.PropertyService;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Chạy 1 lần khi Tomcat khởi động: tự tay new các đối tượng và truyền vào nhau qua constructor,
 * rồi cất vào ServletContext để các Servlet lấy ra dùng.
 */
@WebListener
public class AppContextListener implements ServletContextListener {
    public static final String PROPERTY_SERVICE = "propertyService";
    public static final String APPOINTMENT_SERVICE = "appointmentService";
    public static final String REVIEW_SERVICE = "reviewService";

    @Override
    public void contextInitialized(ServletContextEvent event) {
        ServletContext context = event.getServletContext();

        // JSP dùng ${ctx} để ghép đường dẫn
        context.setAttribute("ctx", context.getContextPath());

        PropertyRepository propertyRepository = new PropertyRepositoryJdbc();
        PropertyService propertyService = new PropertyService(propertyRepository);
        context.setAttribute(PROPERTY_SERVICE, propertyService);

        AppointmentRepository appointmentRepository = new AppointmentRepositoryJdbc();
        AppointmentService appointmentService = new AppointmentService(appointmentRepository);
        context.setAttribute(APPOINTMENT_SERVICE, appointmentService);

        ReviewRepository reviewRepository = new ReviewRepositoryJdbc();
        ReviewService reviewService = new ReviewService(reviewRepository);
        context.setAttribute(REVIEW_SERVICE, reviewService);

        // Thêm tính năng mới: new XxxRepository -> new XxxService(repo) -> context.setAttribute(...)
        context.log("Apartment web khoi dong (PostgreSQL)");
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        Database.shutdown();
    }
}
