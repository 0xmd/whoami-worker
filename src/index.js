import TEMPLATE from './template.js';

export default {
    async fetch(request, env) {
      // Extract info from headers
      const headers = Object.fromEntries(request.headers);
      const email = headers["cf-access-authenticated-user-email"] || "Unknown User";
      const country = headers["cf-ipcountry"] || "Unknown";
      const timestamp = new Date().toISOString();
      
      // Split and inspect URL
      const url = new URL(request.url);
      const pathParts = url.pathname.split('/');
      
      // If is a flag request fetch and return flag
      if (pathParts.length >= 3 && pathParts[1] === 'whoami' && pathParts[2].length > 0) {
        
        const countryCode = pathParts[2].toLowerCase();
        
        try {
          const flagObject = await env.R2_BUCKET.get(`${countryCode}.svg`);
          
          if (flagObject === null) {
            return new Response("Flag not found", { status: 404 });
          }
          
          return new Response(flagObject.body, {
            headers: {
              "Content-Type": "image/svg+xml",
              "Cache-Control": "public, max-age=86400"
            }
          });
        } 
        catch (error) {
          return new Response("Error getting flag", { status: 500 });
        }
      }
      
      // Else return HTML response
      let html = TEMPLATE;
      html = html.replace('{{EMAIL}}', email);
      html = html.replace('{{TIMESTAMP}}', timestamp);
      html = html.replace(/{{COUNTRY}}/g, country);
      
      return new Response(html, {
        headers: {
          "Content-Type": "text/html"
        }
      });
    }
  };
