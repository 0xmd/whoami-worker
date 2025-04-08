export default `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Authentication Information</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      line-height: 1.6;
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    .auth-info {
      background-color: #f0f5ff;
      border-left: 4px solid #f38020;
      padding: 15px;
      border-radius: 4px;
    }
    a {
      color: #f38020;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <div class="auth-info">
    {{EMAIL}} authenticated at {{TIMESTAMP}} from <a href="https://tunnel.fl4re.com/whoami/{{COUNTRY}}">{{COUNTRY}}</a>
  </div>
</body>
</html>`;
