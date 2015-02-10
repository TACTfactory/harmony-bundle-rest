<@header?interpret />
package ${data_namespace};

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;
import java.util.List;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.HttpVersion;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.conn.ConnectTimeoutException;
import org.apache.http.entity.StringEntity;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.auth.BasicScheme;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.CoreProtocolPNames;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.params.HttpProtocolParams;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;

import android.text.TextUtils;
import android.util.Log;

import ${project_namespace}.${project_name?cap_first}Application;

/**
 * Rest Client Class.
 */
public class RestClient {
    /** WebService TAG. */
    private final static String TAG = "WebService";
    
    /** Scheme HTTP. */
    public final static String SCHEME_HTTP = "http";
    /** Scheme HTTPS. */
    public final static String SCHEME_HTTPS = "https";

    /** Web debug state. */
    public boolean debugWeb = true;
    /** File TAG. */
    public String FILE_TAG = "userfile";

    /** httpClient {@link DefaultHttpClient}. */
    protected DefaultHttpClient httpClient;
    /** request {@link HttpRequest}. */
    protected HttpRequest request;
    /** response {@link HttpResponse}. */
    protected HttpResponse response;
    /** statusCode Http result code. */
    protected int statusCode;

    /** serviceName WebService name. */
    protected String serviceName;
    /** Http port. */
    protected int port = 80;
    /** Rest Scheme. */
    protected String scheme;
    /** WebService Authentification. */
    protected String login, password;
    /** Device Token. */
    protected String sessionId, CSRFtoken;

    /**
     * Constructor.
     * @param serviceName The serviceName should be the name of the Service
     *     you are going to be using.
     */
    public RestClient(String serviceName) {
        this(serviceName, 80, SCHEME_HTTP);
    }

    /**
     * Constructor.
     * @param serviceName The serviceName should be the name of the Service
     *     you are going to be using.
     */
    public RestClient(String serviceName, int port, String scheme) {
        HttpParams myParams = new BasicHttpParams();
        
        // Set timeout
        myParams.setParameter(CoreProtocolPNames.PROTOCOL_VERSION,
            HttpVersion.HTTP_1_1);
        HttpConnectionParams.setConnectionTimeout(myParams, 30000);
        HttpConnectionParams.setSoTimeout(myParams, 20000);
        HttpProtocolParams.setUseExpectContinue(myParams, true);
        
        this.httpClient = new DefaultHttpClient(myParams);
        this.serviceName = serviceName;
        this.port = port;
        this.scheme = scheme;
    }

    /**
     * Set WebService authentification.
     * @param login WebService User Name
     * @param password WebService Password
     */
    public void setAuth(String login, String password) {
        this.login = login;
        this.password = password;
    }
    
    /**
     * Get Session Index.
     * @return sessionId
     */
    public String getSessionId() {
        return this.sessionId;
    }
    
    /**
     * Get Token.
     * @return CSRFtoken
     */
    public String getCSRFToken() {
        return this.CSRFtoken;
    }
    
    /**
     * Set CSRFtoken.
     * @param CSRFtoken Token to set
     */
    public void setCSRFtoken(String CSRFtoken) {
        this.CSRFtoken = CSRFtoken;
    }
    
    /**
     * Get Request status code.
     * @return statusCode
     */
    public int getStatusCode() {
        return this.statusCode;
    }
    
    /**
     * Send REST request on WebService.
     * @param verb {@link Verb}
     * @param path URI path
     * @param jsonParams JSON parameter
     * @return result Return entity result or null if request has fail.
     * @throws Exception {@link Exception}
     */
    public String invoke(Verb verb, String path, JSONObject  jsonParams)
            throws Exception {
        return this.invoke(verb, path, jsonParams, null);
    }
    
    /**
     * Send REST request on WebService.
     * @param verb {@link Verb}
     * @param path URI path
     * @param jsonParams JSON parameter
     * @param headers {@link Header}
     * @return result Return entity result or null if request has fail.
     * @throws Exception {@link Exception}
     */
    public String invoke(Verb verb, String path, JSONObject  jsonParams,
            List<Header> headers) throws Exception {
        //EncodingTypes charset=serviceContext.getCharset();
        long startTime = 0, endTime = 0;
        String result = null;
        this.statusCode = 404;
        
        HttpResponse response = null;
        HttpHost targetHost = new HttpHost(
            this.serviceName, this.port, this.scheme);
        
        //HttpEntity entity = this.buildMultipartEntity(params);
        HttpEntity entity = null;
        
        if (jsonParams != null && jsonParams.has("file")) {
            entity = this.buildMultipartEntity(jsonParams);
        }
        else {
            entity = this.buildJsonEntity(jsonParams);
        }
        
        HttpRequest request = this.buildHttpRequest(
            verb, path, entity, headers);
        
        if (this.login != null && this.password != null) {
            request.addHeader(BasicScheme.authenticate(
                new UsernamePasswordCredentials(this.login, this.password),
                "UTF-8", false));
        }
        
        if (!TextUtils.isEmpty(this.CSRFtoken)) {
            request.addHeader("X-CSRF-Token", this.CSRFtoken);
        }
        
        try {
            if (debugWeb) {
                startTime = System.currentTimeMillis();
            }
            
            response = this.httpClient.execute(targetHost, request);
            this.statusCode = response.getStatusLine().getStatusCode();
            
            this.readHeader(response);
            
            if (debugWeb) {
                endTime = System.currentTimeMillis();
            }
            
            // we assume that the response body contains the error message
            HttpEntity resultEntity = response.getEntity();
            
            if (resultEntity != null) {
                result = EntityUtils.toString(resultEntity, HTTP.UTF_8);
            }
            
            if (debugWeb && ${project_name?cap_first}Application.DEBUG) {
                final long endTime2 = System.currentTimeMillis();
                
                //System.out.println(
                //    "The REST response is:\n " + serviceResponse);
                Log.d(TAG, "Time taken in REST operation : "
                    + (endTime - startTime) + " ms. => ["+ verb +"]" + path);
                Log.d(TAG, "Time taken in service response construction : "
                    + (endTime2 - endTime) + " ms.");
            }
        
        } catch (ConnectTimeoutException e){
            Log.e(TAG, "Connection timed out. The host may be unreachable.");
            e.printStackTrace();
            
            throw new Exception(e.getMessage());
        } catch (IOException e) {
            Log.e(TAG, e.getCause().getMessage());
            
            throw new Exception(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            
            throw e;
        } finally {
            this.httpClient.getConnectionManager().shutdown();
        }
        
        return result;
    }
    
    /**
     * Clear all cookies on CookieStore.
     */
    public void clearCookies() {
        this.httpClient.getCookieStore().clear();
    }
    
    /**
     * Check if HTTP client is not null and show message if is null
     * show nothing.
     */
    public void abort() {
        try {
        if (httpClient != null) {
            System.out.println("Abort.");
            //httpPost.abort();
        }
        } catch (Exception e) {
            System.out.println("Your App Name Here" + e);
        }
    }
    
    /**
     * Read Header and set value in token.
     * @param responce Response header to read
     */
    protected void readHeader(HttpResponse responce) {
        if (responce.containsHeader("csrf-token")) {
            this.CSRFtoken = responce.getFirstHeader("csrf-token").getValue();
        }
    }
    
    /**
     * Build {@link HttpEntity} with {@link JSONObject}.
     * @param json {@link JSONObject} To convert
     * @return entity Conversion result
     */
    protected HttpEntity buildJsonEntity(JSONObject json) {
        StringEntity entity = null;
        
        if (json != null) {
            try {
                entity = new StringEntity(json.toString(), "UTF-8");
            } catch (UnsupportedEncodingException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        
        return entity;
    }
    
    /**
     * Build {@link MultipartEntity} with JSON parameter.
     * @param jsonParams JSON parameter to convert {@link JSONObject}
     * @return entity {@link MultipartEntity}
     */
    protected HttpEntity buildMultipartEntity(JSONObject jsonParams) {
        MultipartEntity entity = new MultipartEntity(
            HttpMultipartMode.BROWSER_COMPATIBLE);
        
        try {
            String path = jsonParams.getString("file");
    
            if (debugWeb && ${project_name?cap_first}Application.DEBUG) {
                Log.d(TAG, "key : file value :" + path);
            }
            
            if (!TextUtils.isEmpty(path)) {
                // File entry
                File file = new File(path);
                FileBody fileBin = new FileBody(file, "application/octet");
                entity.addPart("file", fileBin);
                
                try {
                    entity.addPart(
                            "file",
                            new StringBody(
                                path,
                                "text/plain",
                                Charset.forName( HTTP.UTF_8 )));
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                    Log.e(TAG, e.getMessage());
                }
            }
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
        return entity;
    }
    
    /**
     * Build HTTP request and return result.
     * @param verb {@link Verb}
     * @param path URI path
     * @param httpEntity {@link HttpEntity}
     * @param headers {@link Header}
     * @return result {@link HttpRequest}
     */
    protected HttpRequest buildHttpRequest(Verb verb, String path,
            HttpEntity httpEntity, List<Header> headers) {
        HttpRequest result;
        
        if (verb == Verb.GET) {
            result = new HttpGet(path);
        } else if (verb == Verb.POST) {
            result = new HttpPost(path);
            
            if (httpEntity != null) {
                ((HttpPost)result).setEntity(httpEntity);
            }
        } else if (verb == Verb.DELETE) {
            result = new HttpDelete(path);
        } else {
            result = new HttpPut(path);
            
            if (httpEntity != null) {
                ((HttpPut)result).setEntity(httpEntity);
            }
        }
        
        if (result !=null) {
            if (headers != null) {
                for (Header header : headers) {
                    result.addHeader(header);
                }
            }
        }
        
        return result;
    }
    
    /**
     * Request Constants.
     * <li> HTTP </li>
     * <li> HTTPS </li>
     * <li> EMPTY_STRING </li>
     * <li> PAIR_SEPARATOR </li>
     * <li> PARAM_SEPARATOR </li>
     * <li> CARRIAGE_RETURN </li>
     */
    public static class RequestConstants {
        /** HTTP Scheme. */
        public static final String HTTP="http";
        /** HTTPS Scheme. */
        public static final String HTTPS="https";
        /** Empty String Scheme. */
        public static final String EMPTY_STRING = "";
        /** Pair Separator Scheme. */
        public static final String PAIR_SEPARATOR = "%3D";
        /** Param Separator Scheme. */
        public static final String PARAM_SEPARATOR = "%26";
        /** Carriage Return Scheme. */
        public static final String CARRIAGE_RETURN = "\r\n";
    }
    
    /**
     * JSON rest method.
     * <li> GET </li>
     * <li> PUT </li>
     * <li> POST </li>
     * <li> DELETE </li>
     */
    public static enum Verb {
        /** HTTP GET request. */
        GET,
        /** HTTP PUT request. */
        PUT,
        /** HTTP POST request. */
        POST,
        /** HTTP DELETE request. */
        DELETE;
    }
}

