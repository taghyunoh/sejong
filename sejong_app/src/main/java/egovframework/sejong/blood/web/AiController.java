/*
package egovframework.sejong.blood.web;

import javax.servlet.http.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.net.URI;
import java.net.http.*;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.*;

import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@SuppressWarnings("serial")
@WebServlet("/ai/chat.do")
public class AiController extends HttpServlet {

    private String base;
    private String apiKey;
    private String model;
    private int timeoutSec;
    private HttpClient client;
    private ObjectMapper om;

    @Override
    public void init() throws ServletException {
        try (InputStream in = getClass().getClassLoader().getResourceAsStream("application.properties")) {
            Properties p = new Properties();
            if (in != null) p.load(in);

            this.base       = sysOrEnv("AI_BASE",   p.getProperty("ai.base", "https://api.openai.com/v1"));
            this.apiKey     = sysOrEnv("AI_KEY",    p.getProperty("ai.key",  ""));
            this.model      = sysOrEnv("AI_MODEL",  p.getProperty("ai.model","gpt-4o-mini"));
            this.timeoutSec = parseInt(p.getProperty("ai.timeoutSec"), 30);
        } catch (Exception e) {
            throw new ServletException("Failed to load application.properties", e);
        }

        if (apiKey == null || apiKey.isBlank()) {
            getServletContext().log("WARNING: ai.key is empty. Set AI_KEY env or ai.key property.");
        }

        this.client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(timeoutSec))
                .build();

        this.om = new ObjectMapper();
    }

    private String sysOrEnv(String key, String fallback) {
        String v = System.getProperty(key);
        if (v == null || v.isBlank()) v = System.getenv(key);
        return (v == null || v.isBlank()) ? fallback : v;
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception ignore) { return def; }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        RequestBody rb;
        try (BufferedReader br = req.getReader()) {
            rb = om.readValue(br, RequestBody.class);
        } catch (Exception e) {
            writeError(resp, 400, "invalid json body");
            return;
        }

        if (rb == null || rb.message == null || rb.message.isBlank()) {
            writeError(resp, 400, "message is required");
            return;
        }

        try {
            String answer = callLlm(rb.message);
            Map<String, String> ok = new HashMap<>();
            ok.put("answer", answer);
            writeJson(resp, 200, om.writeValueAsString(ok));
        } catch (Exception e) {
            getServletContext().log("LLM call failed", e);
            writeError(resp, 500, e.getMessage());
        }
    }

    private String callLlm(String userMessage) throws Exception {
        // 요청 객체 생성
        Map<String, Object> req = new HashMap<>();
        req.put("model", model);
        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(Map.of("role","system","content","You are a helpful assistant."));
        messages.add(Map.of("role","user","content", userMessage));
        req.put("messages", messages);

        String payload = om.writeValueAsString(req);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(base + "/chat/completions"))
                .timeout(Duration.ofSeconds(timeoutSec))
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", "application/json; charset=UTF-8")
                .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        int sc = response.statusCode();
        String body = response.body();

        if (sc / 100 != 2) {
            throw new IOException("Upstream status " + sc + " body=" + safeSnippet(body));
        }

        OpenAiResponse parsed = om.readValue(body, OpenAiResponse.class);
        if (parsed.choices == null || parsed.choices.isEmpty()
                || parsed.choices.get(0).message == null) {
            return "(no content)";
        }
        String content = parsed.choices.get(0).message.content;
        return (content == null || content.isBlank()) ? "(no content)" : content;
    }

    public static class RequestBody {
        public String message;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class OpenAiResponse {
        public List<Choice> choices;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Choice {
        public Message message;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Message {
        public String role;
        public String content;
    }

    private void writeError(HttpServletResponse resp, int code, String msg) throws IOException {
        resp.setStatus(code);
        Map<String, String> err = new HashMap<>();
        err.put("error", msg == null ? "unknown" : msg);
        writeJson(resp, code, om.writeValueAsString(err));
    }

    private void writeJson(HttpServletResponse resp, int code, String json) throws IOException {
        resp.setStatus(code);
        try (PrintWriter w = resp.getWriter()) { w.write(json); }
    }

    private String safeSnippet(String s) {
        if (s == null) return "";
        s = s.replace("\n"," ").replace("\r"," ");
        return (s.length() > 300) ? s.substring(0, 300) + "…" : s;
    }
}
*/