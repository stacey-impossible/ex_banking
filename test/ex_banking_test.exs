defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  describe "deposit/3" do
    test "doesn't add amount for non-existing user" do
      assert {:error, :user_does_not_exist} = ExBanking.deposit("test", 20, "RUB")
    end

    test "doesn't add amount with invalid input" do
      ExBanking.create_user("test1")
      assert {:error, :wrong_arguments} = ExBanking.deposit(:test1, 20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.deposit("test1", 20, :RUB)
      assert {:error, :wrong_arguments} = ExBanking.deposit("test1", -20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.deposit("test1", "20", "RUB")
    end

    test "adds amounts in different currencies correctly" do
      ExBanking.create_user("test2")
      assert {:ok, 20} = ExBanking.deposit("test2", 20, "RUB")
      assert {:ok, 40} = ExBanking.deposit("test2", 20, "RUB")
      assert {:ok, 20} = ExBanking.deposit("test2", 20, "EUR")
      assert {:ok, 35} = ExBanking.deposit("test2", 15, "EUR")
    end
  end

  describe "withdraw/3" do
    test "doesn't withdraw amount for non-existing user" do
      assert {:error, :user_does_not_exist} = ExBanking.withdraw("test", 20, "RUB")
    end

    test "doesn't withdraw amount with invalid input" do
      ExBanking.create_user("test1")
      assert {:error, :wrong_arguments} = ExBanking.withdraw(:test1, 20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.withdraw("test1", 20, :RUB)
      assert {:error, :wrong_arguments} = ExBanking.withdraw("test1", -20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.withdraw("test1", "20", "RUB")
    end

    test "doesn't withdraw if there is not enough money" do
      ExBanking.create_user("test3")
      assert {:error, :not_enough_money} = ExBanking.withdraw("test3", 20, "RUB")
      ExBanking.deposit("test2", 10, "RUB")
      assert {:error, :not_enough_money} = ExBanking.withdraw("test3", 20, "RUB")
    end

    test "doesn't change balance when wihdraw 0" do
      ExBanking.create_user("test4")
      assert {:ok, 0} = ExBanking.withdraw("test4", 0, "RUB")
      ExBanking.deposit("test4", 20, "RUB")
      assert {:ok, 20} = ExBanking.withdraw("test4", 0, "RUB")
    end

    test "withdraws amounts in different currencies correctly" do
      ExBanking.create_user("test5")
      assert {:ok, 20} = ExBanking.deposit("test5", 20, "RUB")
      assert {:ok, 10} = ExBanking.withdraw("test5", 10, "RUB")
      assert {:ok, 20} = ExBanking.deposit("test5", 20, "EUR")
      assert {:ok, 5} = ExBanking.withdraw("test5", 15, "EUR")
    end
  end

  describe "get_balance/3" do
    test "doesn't get balance of non-existing user" do
      assert {:error, :user_does_not_exist} = ExBanking.get_balance("test", "RUB")
    end

    test "doesn't get balance with invalid input" do
      ExBanking.create_user("test6")
      assert {:error, :wrong_arguments} = ExBanking.get_balance(:test6, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.get_balance("test6", :RUB)
    end

    test "gets balances in different currencies correctly" do
      ExBanking.create_user("test7")
      assert {:ok, 20} = ExBanking.deposit("test7", 20, "RUB")
      assert {:ok, 20} = ExBanking.get_balance("test7", "RUB")
      assert {:ok, 0} = ExBanking.get_balance("test7", "EUR")
    end
  end
end
