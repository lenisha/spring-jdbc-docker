package tutorial;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.orm.jpa.EntityManagerFactoryInfo;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.sql.DataSource;

@Controller
public class UsersController {

    @PersistenceContext
    private EntityManager entityManager;
    protected static final Logger logger = LogManager.getLogger(UsersController.class);

    @RequestMapping("/users")
    public String users(Model model) {

        logger.info("INFO - Retrieveing Users");
        logger.debug("DEBUG - Retrieveing Users");

        model.addAttribute("users", entityManager.createQuery("select u from User u").getResultList());
        
        return "users";
    }

    @RequestMapping("/users100")
    public String users100(Model model) {

        logger.info("INFO - Retrieveing 100 Users");
        logger.debug("DEBUG - Retrieveing 100 Users");

        DataSource dataSource = null;
        Connection conn = null; 
        PreparedStatement stmt = null;
        ResultSet rs = null; 
        
        try { 
            EntityManagerFactoryInfo info = (EntityManagerFactoryInfo) entityManager.getEntityManagerFactory();
            dataSource = info.getDataSource();

            ArrayList<User> userList = new ArrayList<User>();
            conn = dataSource.getConnection();
            
            stmt = conn.prepareStatement("SELECT TOP 100 * from usr");
            stmt.setQueryTimeout(120);
            rs = stmt.executeQuery();

            while(rs.next()) {
                User user = new User();
                user.setName(rs.getString("name"));
                user.setId(new Long(rs.getString("id")));
                userList.add(user);
            }

            model.addAttribute("users", userList);

        } catch (SQLException ex) {
            logger.info("INFO - UserController Exception caught " + ex.getMessage());
            model.addAttribute("error", ex.getMessage());
            ex.printStackTrace();
        } finally {
            try {
                if ( stmt != null) stmt.close();
                if ( rs != null) rs.close();
                if ( conn != null ) conn.close();
            } catch (Exception exf) {
                logger.info("INFO - UserController Exception caught in close " + exf.getMessage());
            }
        }
        
        return "users";
    }

    @RequestMapping(value = "/create-user", method = RequestMethod.GET)
    public String createUser(Model model) {
        return "create-user";
    }

    @RequestMapping(value = "/create-user", method = RequestMethod.POST)
    @Transactional
    public String createUser(Model model, String name) {

        logger.info("INFO - Creating Users");
        logger.debug("DEBUG - Creating Users");

        User user = new User();
        user.setName(name);

        entityManager.persist(user);

        return "redirect:/users.html";
    }
}
