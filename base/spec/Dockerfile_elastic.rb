# spec/Dockerfile_spec.rb

require "serverspec"
require "docker"

Docker.validate_version!

describe "Dockerfile" do
  before(:all) do
    docker_username = "docker.elastic.co/elasticsearch"
    package_name    = "elasticsearch"
    package_version = "7.3.0"

    # check for package version major usage
    if package_version.match(/(\d+).x/)
        puts "[INFO] regex match found"
        package_version = package_version.match(/(\d+).x/)[1]
    end

    image = Docker::Image.get(
      "#{docker_username}/#{package_name}:#{package_version}"
    )

    # https://github.com/mizzy/specinfra
    # https://docs.docker.com/engine/api/v1.24/#31-containers
    # https://github.com/swipely/docker-api
    # https://serverspec.org/resource_types.html
    set :os, family: :redhat
    set :backend, :docker
    set :docker_image, image.id
  end

  def os_version
    command("cat /etc/*-release").stdout
  end

  def sys_user
    command("whoami").stdout.strip
  end



  it "runs the right version of Centos" do
    expect(os_version).to include("CentOS")
    expect(os_version).to include("7.6.1810")
  end

  it "runs as root user" do
    expect(sys_user).to eql("root")
  end



  describe package("/usr/share/elasticsearch/jdk/bin/java --version") do
    it { should be_installed.with_version("openjdk 12.0.1 2019-04-16") }
  end

  describe package("/usr/share/elasticsearch/bin/elasticsearch --version") do
    it { should be_installed.with_version("Version: 7.3.0") }
  end
end
