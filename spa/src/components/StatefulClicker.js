import React from "react";

export default props => {
  const { isActive, onClick, inert = "Refresh", active = "Loading" } = props;
  return isActive ? (
    <div>{active}...</div>
  ) : (
    <div className="clickable link" onClick={onClick}>
      {inert}
    </div>
  );
};
