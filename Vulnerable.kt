import java.io.*
import javax.servlet.http.*

class VulnerableServlet : HttpServlet() {
    // Vulnerability 1: Command Injection
    fun execCommand(req: HttpServletRequest) {
        Runtime.getRuntime().exec(req.getParameter("cmd"))
    }

    // Vulnerability 2: Insecure Deserialization
    fun insecureDeserialize(req: HttpServletRequest) {
        ObjectInputStream(req.inputStream).readObject()
    }

    // Vulnerability 3: Path Traversal
    fun pathTraversal(req: HttpServletRequest, resp: HttpServletResponse) {
        FileInputStream(req.getParameter("filename")).copyTo(resp.outputStream)
    }

    // Vulnerability 4: SQL Injection
    fun sqlInjection(req: HttpServletRequest) {
        // Placeholder. Replace with actual database operations.
        val statement = "SELECT * FROM users WHERE username = '${req.getParameter("username")}'"
    }

    // Vulnerability 5: Open Redirect
    fun openRedirect(resp: HttpServletResponse, location: String) {
        resp.sendRedirect(location)
    }

    // Vulnerability 6: Weak Hashing
    fun weakHashing(password: String) {
        password.hashCode()
    }

    // Vulnerability 7: XML External Entity (XXE)
    fun xxe(req: HttpServletRequest) {
        // Placeholder. Replace with actual XML parsing operations.
        val parserFactory = javax.xml.parsers.DocumentBuilderFactory.newInstance()
        parserFactory.isNamespaceAware = true
        val parser = parserFactory.newDocumentBuilder()
        val document = parser.parse(req.inputStream)
    }

    // Vulnerability 8: Server Side Request Forgery (SSRF)
    fun ssrf(req: HttpServletRequest) {
        java.net.URL(req.getParameter("url")).readText()
    }

    // Vulnerability 9: Cross-Site Scripting (XSS)
    fun xss(resp: HttpServletResponse, content: String) {
        resp.writer.write(content)
    }

    // Vulnerability 10: Use of Assert Statement
    fun assertUsage(req: HttpServletRequest) {
        assert(req.getParameter("isAdmin") == "true") { "You must be an admin!" }
    }
}
