import React from 'react';
import Inflected from "../Inflected";

export default ({ count, itemName, pluralItemName }) => {

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
        </span>
      )}
    </div>
  );
};
