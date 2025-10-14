require 'test_helper'

class PriceUpdatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @price_update = price_updates(:one)
  end

  # test "should get index" do
  #   get price_updates_url
  #   assert_response :success
  # end

  # test "should get new" do
  #   get new_price_update_url
  #   assert_response :success
  # end

  # test "should create price_update" do
  #   assert_difference('PriceUpdate.count') do
  #     post price_updates_url, params: { price_update: { company_id: @price_update.company_id, datetime: @price_update.datetime, price: @price_update.price } }
  #   end

  #   assert_redirected_to price_update_url(PriceUpdate.last)
  # end

  # test "should show price_update" do
  #   get price_update_url(@price_update)
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get edit_price_update_url(@price_update)
  #   assert_response :success
  # end

  # test "should update price_update" do
  #   patch price_update_url(@price_update), params: { price_update: { company_id: @price_update.company_id, datetime: @price_update.datetime, price: @price_update.price } }
  #   assert_redirected_to price_update_url(@price_update)
  # end

  # test "should destroy price_update" do
  #   assert_difference('PriceUpdate.count', -1) do
  #     delete price_update_url(@price_update)
  #   end

  #   assert_redirected_to price_updates_url
  # end
end
