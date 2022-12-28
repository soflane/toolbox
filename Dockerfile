FROM alpine
LABEL maintainer="Soflane <dev@ayoute.be>"
RUN apk add --update --no-cache git \
            py3-pip go make \
            nano bash curl libcurl ncurses \
            # whiptail & dialog
            newt dialog\
            # WPscan requirements
            ruby ruby-dev libffi-dev gcc zlib-dev procps sqlite-dev musl-dev \
            py3-setuptools py3-wheel py3-aiohttp py3-frozenlist py3-multidict py3-yarl &&\
            # Nexfil requirements
            # py3-tldextract py3-grequests py3-packaging
\  
    # Install Nexfil 
    git clone https://github.com/thewhiteh4t/nexfil.git /tools/nexfil &&\
    chmod -R 751 /tools &&\
    sed -i 's#loc_data =.*#loc_data = '\'/output/\''#' /tools/nexfil/nexfil.py &&\
    mkdir -p /output /root/.local/share/nexfil/ &&\
    pip3 install -r /tools/nexfil/requirements.txt 


# Add go modules to PATH 
ENV PATH="${PATH}:/root/go/bin"
ENV PATH="${PATH}:/tools/nexfil"

# Install Mosint
RUN go install -v github.com/alpkeskin/mosint@latest


# Install wpscan 
RUN gem install nokogiri wpscan

VOLUME [ "/output" ]
#Copy bash script
WORKDIR /tools
COPY main.sh /tools/main.sh  
CMD [ "/tools/main.sh" ]