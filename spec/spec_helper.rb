require 'bundler'
Bundler.require :test

service = Arkaan::Utils::MicroService.instance
  .register_as('permissions')
  .from_location(__FILE__)
  .in_test_mode