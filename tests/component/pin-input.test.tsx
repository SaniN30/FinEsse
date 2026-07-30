import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { PinInput } from "@/components/auth/PinInput";

function Wrapper({ length = 4 }: { length?: number }) {
  const onChange = vi.fn();
  return { onChange, ui: <PinInput length={length} value="" onChange={onChange} label="PIN" /> };
}

describe("PinInput", () => {
  it("renders one input per digit", () => {
    const { ui } = Wrapper({ length: 6 });
    render(ui);
    expect(screen.getAllByLabelText(/PIN digit/)).toHaveLength(6);
  });

  it("advances focus to the next box after typing a digit", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<PinInput length={4} value="" onChange={onChange} label="PIN" autoFocus />);

    const boxes = screen.getAllByLabelText(/PIN digit/) as HTMLInputElement[];
    await user.type(boxes[0], "5");

    expect(onChange).toHaveBeenCalledWith("5");
    expect(boxes[1]).toHaveFocus();
  });

  it("only accepts numeric characters", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<PinInput length={4} value="" onChange={onChange} label="PIN" />);

    const boxes = screen.getAllByLabelText(/PIN digit/) as HTMLInputElement[];
    await user.type(boxes[0], "a");

    expect(onChange).toHaveBeenCalledWith("");
  });
});
