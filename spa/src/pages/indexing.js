import React, { Component, PureComponent } from "react";
import Grid from "../components/grid/Grid";
import renderItem from "../utils/grid/render-item";
import "./transform.css";
import api from "../utils/api";

class IndexingItemRenderer extends PureComponent {
  render() {
    return renderItem({
      columns: [
        "id",
        "index_batch_id",
        "status",
        "error_count",
        "status_reason",
        "start_datetime",
        "stop_datetime",
        "elapsed"
      ],
      formatters: [
        (value, index) => index + 1,
        null,
        null,
        null,
        null,
        value => value && new Date(value).toLocaleString(),
        value => value && new Date(value).toLocaleString(),
        null
      ],
      classNames: [
        "clickable",
        "clickable",
        "clickable",
        "clickable link",
        "clickable statusReason",
        "clickable",
        "clickable",
        "clickable"
      ],
      ...this.props
    });
  }
}

// index_batch_error_id	index_batch_id	indexed_item_type	indexed_item_id	messageindex_batch_error_id index_batch_id indexed_item_type  indexed_item_id message
// -------------------- -------------- ------------------ --------------- -----------------------------------------------
// 8                    1              CatModels::Product 1580362         comparison of BigDecimal with BigDecimal failed
class IndexingErrorItemRenderer extends PureComponent {
  render() {
    return renderItem({
      columns: [
        "index_batch_error_id",
        "index_batch_id",
        "indexed_item_type",
        "indexed_item_id",
        "message"
      ],
      formatters: new Array(5),
      classNames: [null, null, null, "link", "statusReason"],
      ...this.props
    });
  }
}

export default class Indexing extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: null
    };
  }

  onSelectItem = item => {
    const itemBatchId = item && item.index_batch_id;
    const deselecting = this.state.selected === itemBatchId;
    this.setState({ selected: null });
    if (!deselecting) {
      setTimeout(() => this.setState({ selected: itemBatchId }), 200);
    }
  };

  onSelectErrorItem = item => {
    const { indexed_item_type: type, indexed_item_id: id } = item;
    if (type !== "CatModels::Product" || !id) {
      alert(`Sorry, not sure how to preview ${type} with id ${id}`);
    } else {
      const url = `/item_indexer/products/${id}`;
      window.open(url, "_blank");
    }
  };

  render() {
    return (
      <div>
        <h2>Indexing Batches</h2>
        <Grid
          width={1350}
          height={400}
          rowHeight={35}
          columnWidths={[50, 100, 100, 50, 450, 225, 225, 150]}
          columnNames={[
            "#",
            "id",
            "status",
            "errors",
            "reason",
            "start",
            "stop",
            "duration"
          ]}
          itemName="indexing"
          itemRenderer={IndexingItemRenderer}
          url={api("index_batches")}
          onSelectItem={this.onSelectItem}
        />
        {this.state.selected && (
          <div className="errors-grid">
            Errors
            <Grid
              width={1350}
              height={400}
              rowHeight={35}
              columnWidths={[100, 100, 200, 150, 800]}
              columnNames={[
                "id",
                "batch id",
                "source item type",
                "source item id",
                "message"
              ]}
              itemName="error"
              itemRenderer={IndexingErrorItemRenderer}
              url={api(`index_batches/${this.state.selected}`)}
              setData={response => response.batch_errors}
              showFooter={true}
              onSelectItem={this.onSelectErrorItem}
            />
          </div>
        )}
      </div>
    );
  }
}
