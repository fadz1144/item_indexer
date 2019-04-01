import React from "react";
import Inflected from "../Inflected";

export default ({
  count,
  itemName,
  pluralItemName,
  isSelected,
  onDeselect
}) => {

  // selection indicator and UI for clearing same
  const Selected = ({ onDeselect }) => {
    return <span> selected <span className="clickable link" onClick={onDeselect}>clear</span></span>
  };

  return (
    <div>
      {count}
      {count !== "none" && (
        <span>
          {" "}
          <Inflected
            count={count}
            singular={itemName}
            plural={pluralItemName}
          />
          {isSelected && <Selected onDeselect={onDeselect}/>}
        </span>
      )}
    </div>
  );
};
