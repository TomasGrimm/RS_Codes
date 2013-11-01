function config_email(email, username, server, password)

% Gmail: smtp.gmail.com

setpref('Internet', 'E_mail', email);
setpref('Internet', 'SMTP_Username', username);
setpref('Internet', 'SMTP_Server', server);
setpref('Internet', 'SMTP_Password', password);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
    'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
