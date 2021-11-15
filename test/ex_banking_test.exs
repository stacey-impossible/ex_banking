defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  setup do
    name = Faker.Person.name()
    ExBanking.create_user(name)

    another_name = Faker.Person.name()
    ExBanking.create_user(another_name)

    {:ok, %{name: name, another_name: another_name}}
  end

  describe "deposit/3" do
    test "doesn't add amount for non-existing user" do
      assert {:error, :user_does_not_exist} = ExBanking.deposit("test", 20, "RUB")
    end

    test "doesn't add amount with invalid input", %{name: name} do
      assert {:error, :wrong_arguments} = ExBanking.deposit(:test, 20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.deposit(name, 20, :RUB)
      assert {:error, :wrong_arguments} = ExBanking.deposit(name, -20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.deposit(name, "20", "RUB")
    end

    test "adds amounts in different currencies correctly", %{name: name} do
      assert {:ok, 20} = ExBanking.deposit(name, 20, "RUB")
      assert {:ok, 40.89} = ExBanking.deposit(name, 20.888, "RUB")
      assert {:ok, 20} = ExBanking.deposit(name, 20, "EUR")
      assert {:ok, 35.45} = ExBanking.deposit(name, 15.454, "EUR")
    end
  end

  describe "withdraw/3" do
    test "doesn't withdraw amount for non-existing user" do
      assert {:error, :user_does_not_exist} = ExBanking.withdraw("test", 20, "RUB")
    end

    test "doesn't withdraw amount with invalid input", %{name: name} do
      assert {:error, :wrong_arguments} = ExBanking.withdraw(:test, 20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.withdraw(name, 20, :RUB)
      assert {:error, :wrong_arguments} = ExBanking.withdraw(name, -20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.withdraw(name, "20", "RUB")
    end

    test "doesn't withdraw if there is not enough money", %{name: name} do
      assert {:error, :not_enough_money} = ExBanking.withdraw(name, 20, "RUB")
      ExBanking.deposit(name, 10, "RUB")
      assert {:error, :not_enough_money} = ExBanking.withdraw(name, 20, "RUB")
    end

    test "doesn't change balance when wihdraw 0", %{name: name} do
      assert {:ok, 0} = ExBanking.withdraw(name, 0, "RUB")
      ExBanking.deposit(name, 20, "RUB")
      assert {:ok, 20} = ExBanking.withdraw(name, 0, "RUB")
    end

    test "withdraws amounts in different currencies correctly", %{name: name} do
      ExBanking.deposit(name, 20, "RUB")
      assert {:ok, 10} = ExBanking.withdraw(name, 10, "RUB")
      ExBanking.deposit(name, 20, "EUR")
      assert {:ok, 4.01} = ExBanking.withdraw(name, 15.986, "EUR")
    end
  end

  describe "get_balance/2" do
    test "doesn't get balance of non-existing user" do
      assert {:error, :user_does_not_exist} = ExBanking.get_balance("test", "RUB")
    end

    test "doesn't get balance with invalid input", %{name: name} do
      assert {:error, :wrong_arguments} = ExBanking.get_balance(:test, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.get_balance(name, :RUB)
    end

    test "gets balances in different currencies correctly", %{name: name} do
      ExBanking.deposit(name, 20, "RUB")
      assert {:ok, 20} = ExBanking.get_balance(name, "RUB")
      assert {:ok, 0} = ExBanking.get_balance(name, "EUR")
    end
  end

  describe "send/4" do
    test "doesn't send from non-existing user", %{name: name} do
      assert {:error, :sender_does_not_exist} = ExBanking.send("test", name, 20, "RUB")
    end

    test "doesn't send to non-existing user", %{name: name} do
      assert {:error, :receiver_does_not_exist} = ExBanking.send(name, "test", 20, "RUB")
    end

    test "doesn't send with invalid input" do
      assert {:error, :wrong_arguments} = ExBanking.send(:test, "test", 20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.send("test", :test, 20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.send("test", "test", -20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.send("test", "test", "20", "RUB")
      assert {:error, :wrong_arguments} = ExBanking.send("test", "test", 20, :RUB)
    end

    test "doesn't withdraw if there is not enough money", %{
      name: name,
      another_name: another_name
    } do
      assert {:error, :not_enough_money} = ExBanking.send(name, another_name, 20, "RUB")
      ExBanking.deposit(name, 10, "RUB")
      assert {:error, :not_enough_money} = ExBanking.send(name, another_name, 20, "RUB")
    end

    test "sends in different currencies correctly", %{name: name, another_name: another_name} do
      ExBanking.deposit(name, 20, "RUB")
      assert {:ok, 15, 5} = ExBanking.send(name, another_name, 5, "RUB")
      ExBanking.deposit(name, 50, "EUR")
      ExBanking.deposit(another_name, 10, "EUR")
      assert {:ok, 25, 35} = ExBanking.send(name, another_name, 25, "EUR")
    end
  end
end
