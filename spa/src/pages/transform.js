import React, { Component, PureComponent } from "react";
import Grid from "../components/grid/Grid";
import renderItem from "../utils/grid/render-item";
import "./transform.css";
import api from "../utils/api";

class TransformItemRenderer extends PureComponent {
  render() {
    return renderItem({
      columns: [
        "id",
        "transform_batch_id",
        "status",
        "status_reason",
        "start_datetime",
        "stop_datetime"
      ],
      formatters: [
        (value, index) => index + 1,
        null,
        null,
        // value => value && value.substring(0, 100),
        null,
        value => value && new Date(value).toLocaleString(),
        value => value && new Date(value).toLocaleString()
      ],
      classNames: ['clickable', 'clickable link', 'clickable long', 'clickable', 'clickable'],
      ...this.props
    });
  }
}

// transform_batch_error_id transform_batch_id source_item_type     source_item_id message
// ------------------------ ------------------ -------------------- -------------- --------------------------------------
// 6250282                  140767             External::XPDM::Item 67048021       Concept skus concept vendor must exist

class TransformErrorItemRenderer extends PureComponent {
  render() {
    return renderItem({
      columns: [
        "transform_batch_error_id",
        "transform_batch_id",
        "source_item_type",
        "source_item_id",
        "message"
      ],
      formatters: new Array(5),
      classNames: [null, null, null, null, "long"],
      ...this.props
    });
  }
}

export default class Transform extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: null
    };
  }

  onSelectItem = item => {
    const itemBatchId = item && item.transform_batch_id;
    const deselecting = this.state.selected === itemBatchId;
    this.setState({selected: null});
    if (!deselecting) {
      setTimeout(() => this.setState({ selected: itemBatchId }), 200);
    }
  };

  render() {
    return (
      <div>
        <h2>Inbound Transform Batches</h2>
        <Grid
          width={1350}
          height={400}
          rowHeight={35}
          columnWidths={[50, 100, 75, 500, 300, 300]}
          columnNames={["#", "id", "status", "reason", "start", "stop"]}
          itemName="transform batch"
          pluralItemName="transform batches"
          itemRenderer={TransformItemRenderer}
          url={api("transform_batches")}
          onSelectItem={this.onSelectItem}
        />
        {this.state.selected && (
          <div className="errors-grid">
            Errors
            <Grid
              width={1350}
              height={400}
              rowHeight={35}
              columnWidths={[100, 100, 300, 150, 650]}
              columnNames={["id", "batch id", "source item type", "source item id", "message"]}
              itemName="error"
              itemRenderer={TransformErrorItemRenderer}
              url={api(`transform_batches/${this.state.selected}`)}
              setData={response => response.batch_errors}
            />
          </div>
        )}
      </div>
    );
  }
}
