# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

project_id            = attribute('project_id')
service_account_email = attribute('service_account_email')
credentials_path      = attribute('credentials_path')

ENV['CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE'] = File.expand_path(
  File.join("../..", credentials_path),
  __FILE__)

control 'project-factory-minimal' do
  title 'Project Factory minimal configuration'

  describe command("gcloud projects describe #{project_id}") do
    its('exit_status') { should be 0 }
    its('stderr') { should eq '' }
  end

  describe command("gcloud services list --project #{project_id}") do
    its('exit_status') { should be 0 }
    its('stderr') { should eq '' }

    its('stdout') { should match(/compute\.googleapis\.com/) }
    its('stdout') { should match(/container\.googleapis\.com/) }
  end

  describe command("gcloud iam service-accounts list --project #{project_id} --format='json(email)'") do
    its('exit_status') { should be 0 }
    its('stderr') { should eq '' }

    let(:service_accounts) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true).map { |entry| entry[:email] }
      else
        []
      end
    end

    it { expect(service_accounts).to include service_account_email }
  end
end
