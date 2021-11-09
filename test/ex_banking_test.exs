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
end
