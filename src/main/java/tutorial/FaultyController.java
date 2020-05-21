package tutorial;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.hibernate.ejb.EntityManagerFactoryImpl;
import org.hibernate.service.jdbc.connections.spi.ConnectionProvider;
import org.springframework.orm.jpa.EntityManagerFactoryInfo;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.sql.DataSource;

@Controller
public class FaultyController {
    
    @PersistenceContext
    private EntityManager em;
    protected static final Logger logger = LogManager.getLogger(FaultyController.class);

    @RequestMapping("/fault")
    public String fault(Model model) {

        logger.info("INFO - FaultyController");
        
        try { 
            EntityManagerFactoryInfo info = (EntityManagerFactoryInfo) em.getEntityManagerFactory();
            DataSource dataSource = info.getDataSource();

             Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT 1");
             stmt.executeQuery();
             
             throw new RuntimeException("Fail me - do not close connection");
        } catch (SQLException ex) {

        }

        model.addAttribute("error", "error");
        
        return "fault";
    }
}