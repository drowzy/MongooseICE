defmodule Fennec.Evaluator.Request do
  @moduledoc false

  alias Jerboa.Params
  alias Jerboa.Format.Body.Attribute
  alias Fennec.TURN

  @spec service(Params.t, Fennec.client_info, Fennec.UDP.server_opts, TURN.t)
    :: {Params.t, TURN.t}
  def service(params, client, server, turn_state) do
    case service_(params, client, server, turn_state) do
      {new_params, new_turn_state} ->
        {response(new_params), new_turn_state}
      new_params ->
        {response(new_params), turn_state}
    end
  end

  defp service_(p, client, server, turn_state) do
    case method(p) do
      :binding ->
        Fennec.Evaluator.Binding.Request.service(p, client, server, turn_state)
      :allocate ->
        Fennec.Evaluator.Allocate.Request.service(p, client, server, turn_state)
    end
  end

  defp method(params) do
    Params.get_method(params)
  end

  defp response(result) do
    case errors?(result) do
      false ->
        success(result)
      true ->
        failure(result)
    end
  end

  defp errors?(%Params{attributes: attrs}) do
     attrs
     |> Enum.any?(&error_attr?/1)
  end

  defp success(params) do
    Params.put_class(params, :success)
  end

  defp failure(params) do
    Params.put_class(params, :failure)
  end

  defp error_attr?(%Attribute.ErrorCode{}), do: true
  defp error_attr?(_), do: false
end
