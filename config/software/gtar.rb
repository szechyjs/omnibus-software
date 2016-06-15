#
# Copyright 2016 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name "gtar"
default_version "1.29"

version("1.29") { source md5: "c57bd3e50e43151442c1995f6236b6e9" }
version("1.28") { source md5: "6ea3dbea1f2b0409b234048e021a9fd7" }

license "GPL-3.0"
license_file "COPYING"

source url: "http://ftp.gnu.org/gnu/tar/tar-#{version}.tar.gz"

relative_path "tar-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  configure_command = [
    "./configure",
    "--prefix=#{install_dir}/embedded",
    "--without-selinux",
  ]

  if nexus? || ios_xr?
    # ios_xr and nexus don't have build in acl support
    configure_command << " --disable-acl"
  elsif aix?
    # AIX has a gross patch that is required since xlc gets confused by too many #ifndefs
    patch_env = env.dup
    patch_env["PATH"] = "/opt/freeware/bin:#{env['PATH']}"
    patch source: "aix_ifndef.patch", plevel: 0, env: patch_env
  end

  command configure_command.join(" "), env: env
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
