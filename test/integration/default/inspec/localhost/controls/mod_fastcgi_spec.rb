#
# Copyright:: (c) 2014 OneHealth Solutions, Inc.
# Copyright:: (c) 2014 Viverae, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# read platform information, see https://github.com/chef/inspec/issues/1396
property = apache_info(File.dirname(__FILE__))

describe 'apache2::mod_fastcgi' do
  expected_module = 'fastcgi'
  subject(:available) { file("#{property[:apache][:dir]}/mods-available/#{expected_module}.load") }
  xit "mods-available/#{expected_module}.load is accurate" do
    expect(available).to be_file
    expect(available).to be_mode 0644
    expect(available.content).to match "LoadModule #{expected_module}_module #{property[:apache][:libexec_dir]}/mod_#{expected_module}.so\n"
  end

  subject(:enabled) { file("#{property[:apache][:dir]}/mods-enabled/#{expected_module}.load") }
  xit "mods-enabled/#{expected_module}.load is a symlink to mods-available/#{expected_module}.load" do
    expect(enabled).to be_linked_to("#{property[:apache][:dir]}/mods-available/#{expected_module}.load")
  end

  subject(:loaded_modules) { command("APACHE_LOG_DIR=#{property[:apache][:log_dir]} #{property[:apache][:binary]} -M") }
  xit "#{expected_module} is loaded" do
    expect(loaded_modules.exit_status).to eq 0
    expect(loaded_modules.stdout).to match(/#{expected_module}_module/)
  end
end
