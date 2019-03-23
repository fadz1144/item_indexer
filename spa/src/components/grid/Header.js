import React from "react";
import px from "../../utils/px";

const positionsFromWidths = columnWidths => {
  let acc = 0;
  return columnWidths.map(val => {
    const current = acc;
    acc += val;
    return current;
  });
};

export default props => {
  const positions = positionsFromWidths(props.columnWidths);
  return (
    <div
      className="Header"
      style={{
        height: px(props.rowHeight),
        position: "relative",
        width: px(props.width),
        border: "0 none"
      }}
    >
      {props.columnNames.map((name, index) => (
        <div
          key={name}
          style={{
            position: "absolute",
            left: px(positions[index]),
            top: "0px",
            height: px(props.rowHeight),
            width: px(props.columnWidths[index])
          }}
        >
          {name}
        </div>
      ))}
    </div>
  );
};
