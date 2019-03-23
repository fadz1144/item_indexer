import React from "react";

export default ({
  columnIndex,
  data,
  rowIndex,
  style,
  columns,
  formatters,
  classNames
}) => {
  // Access the data source using the "data" prop:
  const value = data[rowIndex][columns[columnIndex]];
  const formatter = formatters[columnIndex];
  const item = !!formatter ? formatter(value, rowIndex) : value;

  const className = `${classNames[columnIndex]} ${
    rowIndex % 2 === 0 ? "even" : "odd"
  }`;

  return (
    <div className={className} data-id={rowIndex} style={style} title={item}>
      {item}
    </div>
  );
};