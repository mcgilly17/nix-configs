{pkgs, ...}: {
  ### Creative applications
  homebrew = {
    brews = [
      "python@3.10"
    ];
    casks = [
      "godot"
      ## Development
      "linear-linear"
      "claude"
      "granola"

      # "google-cloud-sdk" #The Cloud SDK is a set of tools for Cloud Platform. It contains gcloud, gsutil, and bq, which you can use to access Google Compute Engine https://cloud.google.com/sdk/"
      # "iterm2" #iTerm2 is a replacement for Terminal and the successor to iTerm https://www.iterm2.com/"
      # "postman" #Postman helps you be more efficient while working with APIs. Using Postman, you can construct complex HTTP requests quickly, organize them in collections,etc. https://www.getpostman.com/"
      # "studio-3t" #Studio 3T, the most powerful MongoDB GUI and IDE available https://studio3t.com/"
      "orbstack"
      # "docker-compose" #Compose is a tool for defining and running multi-container Docker applications https://docs.docker.com/compose/"
      # "ngrok" #ngrok provides a real-time web UI where you can introspect all HTTP traffic running over your tunnels https://ngrok.com/"
      # "minikube" #Minikube is a tool that makes it easy to run Kubernetes locally https://github.com/kubernetes/minikube"
      # "reactotron" #unclear"
    ];
  };
}
