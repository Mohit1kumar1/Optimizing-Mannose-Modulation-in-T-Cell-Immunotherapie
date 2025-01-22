# Use a base image with R pre-installed
FROM rocker/r-ver:4.4.2

LABEL maintainer="Mohit Kumar mohitkumar384400@gmail.com"

# Environment variables for reproducibility
ENV RENV_VERSION=1.0.0
ENV R_BIOC_VERSION=3.18
ENV CRAN="https://cloud.r-project.org"

# Create app directory
# RUN mkdir /app

# Copy pipeline files
COPY ./main.nf /app/main.nf 
COPY ./nextflow.config /app/nextflow.config
COPY ./scripts /app/scripts
COPY ./data /app/data


WORKDIR /app

# Install system-level dependencies, Java, and R libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    openjdk-11-jdk \
    libhdf5-dev libcurl4-openssl-dev libssl-dev libxml2-dev libgit2-dev \
    libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev \
    libjpeg-dev zlib1g-dev && \
    R -e "install.packages(c('Matrix', 'limma', 'devtools', 'Seurat', 'BiocManager'), repos = 'http://cran.r-project.org')" && \
    R -e "BiocManager::install(c('rhdf5', 'clusterProfiler', 'org.Mm.eg.db', 'org.Hs.eg.db', 'AnnotationDbi', 'KEGGREST'))" && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Nextflow
RUN curl -s https://get.nextflow.io | bash && \
    mv nextflow /usr/local/bin/ && \
    chmod +x /usr/local/bin/nextflow

# Create non-root user and set permissions
RUN useradd -m pipeline_user && \
    chown -R pipeline_user:pipeline_user /app
USER pipeline_user

# Set entrypoint for Nextflow
CMD ["nextflow", "run", "main.nf"]