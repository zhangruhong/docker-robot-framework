FROM fedora:29

MAINTAINER Paul Podgorsek <ppodgorsek@users.noreply.github.com>
LABEL description Robot Framework in Docker.

# Setup volumes for input and output
VOLUME /opt/robotframework/reports
VOLUME /opt/robotframework/tests

# Setup X Window Virtual Framebuffer
ENV SCREEN_COLOUR_DEPTH 24
ENV SCREEN_HEIGHT 1080
ENV SCREEN_WIDTH 1920

# Set number of threads for parallel execution
# By default, no parallelisation
ENV ROBOT_THREADS 1

# Dependency versions
ENV CHROMIUM_VERSION 73.0.*
ENV FAKER_VERSION 4.2.0
ENV FIREFOX_VERSION 64.0*
ENV GECKO_DRIVER_VERSION v0.22.0
ENV PABOT_VERSION 0.45
ENV PYTHON_PIP_VERSION 18.0*
ENV REQUESTS_VERSION 0.4.7
ENV ROBOT_FRAMEWORK_VERSION 3.0.4
ENV SELENIUM_LIBRARY_VERSION 3.2.0
ENV XVFB_VERSION 1.20.*

# Install system dependencies
RUN dnf upgrade -y \
  && dnf install -y \
#     chromedriver-$CHROMIUM_VERSION \
#     chromium-$CHROMIUM_VERSION \
#     firefox-$FIREFOX_VERSION \
    python2-pip-$PYTHON_PIP_VERSION \
    xauth \
    xorg-x11-server-Xvfb-$XVFB_VERSION \
    which \
    wget \
  && dnf clean all

# Install Robot Framework and Selenium Library
 RUN pip install \
  robotframework==$ROBOT_FRAMEWORK_VERSION \
  robotframework-faker==$FAKER_VERSION \
  robotframework-pabot==$PABOT_VERSION \
  asn1crypto==0.24.0\
  beautifulsoup4==4.6.3\
  certifi==2018.8.24\
  cffi==1.11.5\
  chardet==3.0.4\
  cryptography==2.3.1\
  datetime==4.2\
  enum34==1.1.6\
  idna==2.7\
  ipaddress==1.0.22\
  jsonpatch==1.23\
  jsonpointer==2.0\
  pip==18.0\
  pycparser==2.18\
  pymysql==0.9.2\
  pytz==2018.5\
  PyYAML==3.13\
  requests==2.19.1\
  robotframework-databaselibrary==1.0.1\
  robotframework-httplibrary==0.4.2\
  robotframework-requests==0.4.8\
  robotframework-ride==1.5.2.1\
  robotframework-selenium2library==3.0.0\
  robotframework-seleniumlibrary==3.1.1\
  robotframework-yamllibrary==0.2.8\
  selenium==3.14.0\
  setuptools==28.8.0\
  six==1.11.0\
  urllib3==1.23\
  waitress==1.1.0\
  webob==1.8.2\
  webtest==2.0.30\
  zope.interface==4.5.0

# Download Gecko drivers directly from the GitHub repository
RUN wget -q "https://github.com/mozilla/geckodriver/releases/download/$GECKO_DRIVER_VERSION/geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz" \
      && tar xzf geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz \
      && mkdir -p /opt/robotframework/drivers/ \
      && mv geckodriver /opt/robotframework/drivers/geckodriver \
      && rm geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz

# Prepare binaries to be executed
COPY bin/chromedriver.sh /opt/robotframework/bin/chromedriver
COPY bin/chromium-browser.sh /opt/robotframework/bin/chromium-browser
COPY bin/run-tests-in-virtual-screen.sh /opt/robotframework/bin/

# FIXME: below is a workaround, as the path is ignored
RUN mv /usr/lib64/chromium-browser/chromium-browser /usr/lib64/chromium-browser/chromium-browser-original \
  && ln -sfv /opt/robotframework/bin/chromium-browser /usr/lib64/chromium-browser/chromium-browser

# Update system path
ENV PATH=/opt/robotframework/bin:/opt/robotframework/drivers:$PATH

# Execute all robot tests
CMD ["run-tests-in-virtual-screen.sh"]
