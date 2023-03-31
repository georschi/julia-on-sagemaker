# Parse command line arguments
args = ARGS
println(args)

# Setup AWS S3 client
# s3 = S3()

# Setup parameters
# Container directories
prefix = "/opt/ml"
input_path = joinpath(prefix, "input", "data")
output_path = joinpath(prefix, "output")
model_path = joinpath(prefix, "model")
code_dir = joinpath(prefix, "code")
inference_code_dir = joinpath(model_path, "code")

if length(args) == 1 && args[1] == "train"
    # This is where the hyperparameters are saved by the estimator on the container instance
    param_path = joinpath(prefix, "input", "config", "hyperparameters.json")
    params = JSON.parsefile(param_path)

    s3_source_code_tar = replace(params["sagemaker_submit_directory"], "\"" => "")
    script = replace(params["sagemaker_program"], "\"" => "")

    bucketkey = replace(s3_source_code_tar, "s3://" => "")
    bucket = replace(first(split(bucketkey, "/")), "\"" => "")
    key = replace(joinpath(split(bucketkey, "/")[2:end]...), "\"" => "")
    
    region = replace(params["sagemaker_region"], "\"" => "")
    aws = global_aws_config(; region=region)
    AWSS3.s3_get_file(bucket, key, "sourcedir.tar.gz")
    run(`tar -xf sourcedir.tar.gz -C $code_dir`)

    @printf("Training started\n")
    include(joinpath(code_dir, script))
    
elseif length(args) == 1 && args[1] == "serve"
    @printf("Inference time\n")
    error("Invalid argument. This container has not yet been made ready to host models")
    
else
    error("Invalid argument. Valid arguments are 'train' and 'serve'.")
end
