# Base Image
FROM nginx:stable
#Copy the index.html file /usr/share/nginx/html/
COPY index.html /usr/share/nginx/html/
#Expose Nginx Port
EXPOSE 80
#Start NginxService
CMD ["nginx", "-g", "daemon off;"]
