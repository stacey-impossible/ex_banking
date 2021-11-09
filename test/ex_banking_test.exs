defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  describe "deposit/3" do
    test "doesn't add amount for non-existing user" do
      assert {:error, :user_does_not_exist} = ExBanking.deposit("test", 20, "RUB")
    end

    test "doesn't add amount with invalid input" do
      ExBanking.create_user("test")
      assert {:error, :wrong_arguments} = ExBanking.deposit(:test, 20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.deposit("test", 20, :RUB)
      assert {:error, :wrong_arguments} = ExBanking.deposit("test", -20, "RUB")
      assert {:error, :wrong_arguments} = ExBanking.deposit("test", "20", "RUB")
    end
  end
end
