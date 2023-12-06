ARG IMAGE=intersystemsdc/irishealth-community:latest
ARG IMAGE=intersystemsdc/iris-community:latest
ARG IMAGE=intersystemsdc/iris-community:2023.1.1.380.0-zpm
FROM $IMAGE

WORKDIR /home/irisowner/dev
 
ARG MODULE="OpenTelemetry-Trace-SOAP"
ARG NAMESPACE="IRISAPP"

## Embedded Python environment
ENV IRISUSERNAME "_SYSTEM"
ENV IRISPASSWORD "SYS"
ENV IRISNAMESPACE "IRISAPP"
ENV PYTHON_PATH=/usr/irissys/bin/
ENV PATH "/home/irisowner/.local/bin:/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"

RUN --mount=type=bind,src=.,dst=. \
    iris start IRIS && \
    iris merge IRIS merge.cpf && \
	iris session IRIS < iris.script && \
    pip3 install -r requirements.txt && \
    iris stop IRIS quietly
