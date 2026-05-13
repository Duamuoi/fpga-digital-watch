import pytest
from conftest import rtl_exists


@pytest.mark.skipif(
    not rtl_exists("restartable_rate_generator.sv"),
    reason="restartable_rate_generator not implemented yet",
)
def test_restartable_rate_generator_edge(cocotb_runner):
    """Dedicated test for CYCLE_COUNT = 1 edge case."""

    cocotb_runner(
        top="restartable_rate_generator",
        sources=["restartable_rate_generator.sv", "mod_n_counter.sv"],
        test_module="tb_restartable_rate_generator_edge",
        parameters={"CYCLE_COUNT": 1},
    )
