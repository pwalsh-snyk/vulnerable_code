import java.sql.*;

public class VulnerableCode {
    private String input;

    public VulnerableCode(String input) {
        this.input = input;
    }

    // Vulnerability 1: SQL Injection
    public void vulnerableSQLQuery() throws SQLException {
        String query = "SELECT * FROM users WHERE username = '" + input + "';";
        Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/db", "user", "password");
        Statement statement = connection.createStatement();
        ResultSet resultSet = statement.executeQuery(query);
        while (resultSet.next()) {
            System.out.println("User ID: " + resultSet.getInt("id") + ", Username: " + resultSet.getString("username"));
        }
        resultSet.close();
        statement.close();
        connection.close();
    }

    // Vulnerability 2: Path Traversal
    public void vulnerableFileAccess() {
        String filePath = "/var/data/files/" + input;
        // Some code to read or write to the file at 'filePath'
        // ...
    }

    // Vulnerability 3: Command Injection
    public void vulnerableCommandExecution() throws IOException {
        String command = "ping " + input;
        Process process = Runtime.getRuntime().exec(command);
        // Process the output
        // ...
    }

    // Vulnerability 4: Cross-Site Scripting (XSS)
    public String vulnerableXSS() {
        return "<div>Welcome, " + input + "</div>";
    }

    // Vulnerability 5: Insecure Deserialization
    public void vulnerableDeserialization(byte[] bytes) throws IOException, ClassNotFoundException {
        ByteArrayInputStream bis = new ByteArrayInputStream(bytes);
        ObjectInput in = new ObjectInputStream(bis);
        Object obj = in.readObject();
        // Use 'obj' without proper validation
        // ...
    }

    // Vulnerability 6: Cross-Site Request Forgery (CSRF)
    // This method does not include CSRF tokens for form submissions
    public String vulnerableCSRF() {
        return "<form action='/updateProfile' method='post'>" +
               "  <input type='text' name='username' value='" + input + "'>" +
               "  <input type='submit' value='Update Profile'>" +
               "</form>";
    }

    // Vulnerability 7: Improper Error Handling
    public void vulnerableErrorHandling() {
        try {
            int result = Integer.parseInt(input);
            System.out.println("Result: " + (100 / result));
        } catch (NumberFormatException e) {
            System.out.println("Error: Invalid number format.");
        } catch (ArithmeticException e) {
            System.out.println("Error: Division by zero.");
        }
    }

    // Vulnerability 8: Unvalidated Redirects and Forwards
    public String vulnerableRedirect() {
        return "redirect:/user/profile?username=" + input;
    }

    // Vulnerability 9: Insufficient Password Management
    // This method does not enforce password complexity rules
    public boolean vulnerableWeakPassword(String password) {
        return password.equals(input);
    }

    // Vulnerability 10: Improper Access Control
    // This method does not properly validate the user's role for access control
    public boolean vulnerableAccessControl(String role) {
        return role.equals("admin");
    }
}
