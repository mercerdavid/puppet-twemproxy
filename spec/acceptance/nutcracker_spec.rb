require 'spec_helper_acceptance'

describe 'default nutcracker service testing', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  describe 'running puppet code for default install' do
    it 'should provision with defaults' do
      pp = <<-EOS

        if versioncmp($::puppetversion,'3.6.1') >= 0 {
          $allow_virtual_packages = hiera('allow_virtual_packages',false)
          Package {
            allow_virtual => $allow_virtual_packages,
          }
        }

        class { 'redis':
          version            => '2.8.19',
        }
        redis::instance { 'redis-6390':
          redis_port         => '6390',
          redis_bind_address => '127.0.0.1'
        }
        redis::instance { 'redis-6391':
          redis_port         => '6391',
          redis_bind_address => '127.0.0.1'
        }
        redis::instance { 'redis-6392':
          redis_port         => '6392',
          redis_bind_address => '127.0.0.1'
        }

        twemproxy::resource::nutcracker { 'redis-twemproxy':
          port                 => '6379',
          nutcracker_hash      => 'fnv1a_64',
          nutcracker_hash_tag  => '',
          distribution         => 'ketama',
          twemproxy_timeout    => '300',

          auto_eject_hosts     => false,
          server_retry_timeout => '500',
          server_failure_limit => '1',

          log_dir              => '/var/log/nutcracker',
          pid_dir              => '/var/run/nutcracker',
          redis                => true,
          statsport            => '22222',

          members              =>  [
           { 
              'ip'         => '127.0.0.1',
              'name'       => 'redis-6390',
              'redis_port' => '6390',
              'weight'     => '1'
            },
            { 
              'ip'         => '127.0.0.1',
              'name'       => 'redis-6391',
              'redis_port' => '6391',
              'weight'     => '1'
            },
            { 
              'ip'         => '127.0.0.1',
              'name'       => 'redis-6392',
              'redis_port' => '6392',
              'weight'     => '1'
            }
          ] 
        }        
      EOS

      apply_manifest(pp, :catch_failures => true)

      shell("ls -l /var/log/nutcracker")

    end

  describe service('redis_6390') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe service('redis_6391') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe service('redis_6392') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe service('redis-twemproxy') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end
   
  end

end
