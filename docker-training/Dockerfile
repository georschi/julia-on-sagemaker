FROM jupyter/datascience-notebook:latest

# Install the AWS CLI:
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip
USER root

RUN ./aws/install

# Install various Python utilities for SageMaker, and PyCall to enable using them from Julia:
# (Pinned to last tested major version for repeatability)
RUN julia -e 'import Pkg; Pkg.update()' && \
   julia -e 'using Pkg; pkg"add PyCall@1"; pkg"precompile"' && \
   julia -e 'import Pkg; Pkg.add(["LIBSVM", "RDatasets", "MLBase", "Plots", "StatsPlots", "Flux","MLDatasets","CUDA","FileIO", "BSON", "AWSS3", "JSON", "AWS"])' && \
   pip install \
       'boto3>=1,<2' \
       'sagemaker>=2,<3' 


ENV PATH="/opt/ml/code:${PATH}"

WORKDIR /opt/ml/code

COPY ./docker-training/run.sh /opt/ml/code/run.sh
COPY ./docker-training/entrypoint.jl /opt/ml/entrypoint.jl

RUN /bin/bash -c 'chmod +x /opt/ml/code/run.sh'

ENTRYPOINT ["/bin/bash", "run.sh"]