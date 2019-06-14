FROM ruby:2.6.3
RUN apt-get update -qq && apt-get upgrade -y

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN apt-get install -y build-essential libpq-dev libxml2-dev libxslt1-dev \
    libfontconfig1 libfontconfig1-dev nodejs unzip xvfb && \
  apt-get clean

# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update && apt-get install -y google-chrome-stable

ARG CHROME_DRIVER_VERSION
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/75.0.3770.8/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && chmod 755 /opt/selenium/chromedriver \
  && ln -fs /opt/selenium/chromedriver /usr/bin/chromedriver \
  && echo "75.0.3770.8" > /root/.chromedriver-version
#RUN echo "75.0.3770.8" > /root/.chromedriver-version


RUN bash -c 'google-chrome --version'

RUN bash -c 'chromedriver --version'

ENV DISPLAY=:20
ADD runxvfb.sh /runxvfb.sh
RUN chmod a+x /runxvfb.sh

RUN bash -c 'ls /'

CMD /runxvfb.sh


ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME
