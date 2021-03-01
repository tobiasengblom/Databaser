
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/portal";
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode) {
        try (PreparedStatement st = conn.prepareStatement("INSERT INTO Registrations VALUES (?, ?)")) {
            st.setString(1, student);
            st.setString(2, courseCode);
            st.executeUpdate();
            return "{\"success\":true}";
            // Here's a bit of useful code, use it or delete it
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode) {
        try (PreparedStatement st = conn.prepareStatement("DELETE FROM Registrations WHERE student = ? AND course ='" + courseCode + "'")) {
            st.setString(1, student);
            //st.setString(2, courseCode);
            int r = st.executeUpdate();
            if (r > 0) {
                return "{\"success\":true}";
            } else {
                return "{\"success\":false, \"error\":\" Student is not registered/waiting \"}";
            }
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException {

        try (PreparedStatement st = conn.prepareStatement(
                // replace this with something more useful
                "SELECT jsonb_build_object(" +
                        "'student', idnr," +
                        "'name', BasicInformation.name," +
                        "'login', login," +
                        "'program', program," +
                        "'branch', branch," +
                        "'finished', (SELECT jsonb_agg (jsonb_build_object (" +
                                    "'course', FinishedCoursesWithNames.name," +
                                    "'code', FinishedCoursesWithNames.course," +
                                    "'credits', FinishedCoursesWithNames.credits," +
                                    "'grade', FinishedCoursesWithNames.grade)) " +
                                    "FROM FinishedCoursesWithNames WHERE student = BasicInformation.idnr)," +
                        "'registered', (SELECT jsonb_agg (jsonb_build_object (" +
                                    "'course', RegistrationsWithNames.name," +
                                    "'code', RegistrationsWithNames.course," +
                                    "'status', status)) " +
                                    "FROM RegistrationsWithNames WHERE student = BasicInformation.idnr)," +
                        "'seminarCourses', (SELECT seminarCourses FROM PathToGraduation WHERE student = BasicInformation.idnr)," +
                        "'mathCredits', (SELECT mathCredits FROM PathToGraduation WHERE student = BasicInformation.idnr)," +
                        "'researchCredits', (SELECT researchCredits FROM PathToGraduation WHERE student = BasicInformation.idnr)," +
                        "'totalCredits', (SELECT totalCredits FROM PathToGraduation WHERE student = BasicInformation.idnr)," +
                        "'canGraduate', (SELECT qualified FROM PathToGraduation WHERE student = BasicInformation.idnr)) " +
                        "AS " +
                        "jsondata " +
                        "FROM " +
                        "BasicInformation " +
                        "WHERE " +
                        "idnr = ? " +
                        "GROUP BY " +
                        "idnr," +
                        "BasicInformation.name," +
                        "login," +
                        "program," +
                        "branch;"
        );) {

            st.setString(1, student);

            ResultSet rs = st.executeQuery();

            if (rs.next())
                return rs.getString("jsondata");
            else
                return "{\"student\":\"does not exist :(\"}";

        }
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e) {
        String message = e.getMessage();
        int ix = message.indexOf('\n');
        if (ix > 0) message = message.substring(0, ix);
        message = message.replace("\"", "\\\"");
        return message;
    }
}